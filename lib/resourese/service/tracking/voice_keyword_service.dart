import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'system_sound_muter.dart';

typedef OnKeywordDetected = void Function(String keyword);
typedef OnSoundLevel = void Function(double dba);

class VoiceKeywordService {
  VoiceKeywordService({
    required this.onKeywordDetected,
    this.onSoundLevel,
  });

  final OnKeywordDetected onKeywordDetected;
  final OnSoundLevel? onSoundLevel;

  final SpeechToText _speech = SpeechToText();
  bool _isMonitoring = false;
  bool _isListening = false;
  bool _isRestarting = false; // guard: tránh đồng thời nhiều restart
  DateTime? _lastDetectedAt;
  String? _cachedLocaleId;

  Timer? _restartTimer; // single timer — cancel cũ trước khi set mới
  Timer? _watchdogTimer;

  static const Duration _pauseFor = Duration(seconds: 8);
  static const Duration _listenFor = Duration(seconds: 50);
  static const Duration _cooldown = Duration(seconds: 5);
  static const Duration _watchdogInterval = Duration(seconds: 20);

  static const List<String> keywords = [
    'help',
    'help me',
    'sos',
    'emergency',
    'save me',
    'danger',
    'accident',
    'call police',
    'call 911',
    'i need help',
    'ok',
    'cứu',
    'cứu với',
    'cứu tôi',
    'giúp tôi',
    'khẩn cấp',
    'nguy hiểm',
    'tai nạn',
  ];

  static const List<String> _fuzzyKeywords = [
    'help',
    'sos',
    'emergency',
    'danger',
    'cứu',
    'khẩn',
  ];

  // ─── Public ───────────────────────────────────────────────────────────────

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    debugPrint('[VOICE] Initializing...');

    final available = await _speech.initialize(
      onError: (error) {
        debugPrint('[VOICE] Error: ${error.errorMsg}');
        _isListening = false;

        if (!_isMonitoring) return;

        // error_busy: quá nhiều restart → delay dài hơn để tránh vòng lặp lỗi
        // error_no_match: bình thường (không nói gì) → restart gần như ngay lập tức
        final delay = switch (error.errorMsg) {
          'error_busy' => const Duration(seconds: 3),
          'error_no_match' || 'error_speech_timeout' => const Duration(milliseconds: 250),
          _ => const Duration(milliseconds: 800),
        };

        // Các lỗi "permanent" trên Android thực ra vẫn restart được
        final canRestart = !error.permanent ||
            error.errorMsg == 'error_speech_timeout' ||
            error.errorMsg == 'error_no_match' ||
            error.errorMsg == 'error_busy' ||
            error.errorMsg == 'error_client';

        if (canRestart) _scheduleRestart(delay);
      },
      onStatus: (status) {
        debugPrint('[VOICE] Status: $status');
        _isListening = status == 'listening';

        if (!_isMonitoring) return;

        // done/notListening → schedule restart gần như ngay (trước đây chờ 1s
        // gây khoảng trống mất mic khá dài, làm rớt từ khoá nói ngay lúc đó)
        if (status == 'done' || status == 'notListening') {
          _scheduleRestart(const Duration(milliseconds: 250));
        }
      },
    );

    if (!available) {
      debugPrint('[VOICE] NOT available — check mic & speech permission');
      return;
    }

    _cachedLocaleId = await _bestLocale();
    debugPrint('[VOICE] Locale: $_cachedLocaleId');

    _isMonitoring = true;
    await _startSession();
    _startWatchdog();
    debugPrint('[VOICE] Monitoring started');
  }

  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;
    _isMonitoring = false;
    _isListening = false;
    _isRestarting = false;
    _restartTimer?.cancel();
    _restartTimer = null;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    await SystemSoundMuter.mute();
    await _speech.stop();
    unawaited(Future.delayed(const Duration(milliseconds: 600), SystemSoundMuter.unmute));
    debugPrint('[VOICE] Stopped');
  }

  bool get isMonitoring => _isMonitoring;

  // ─── Capture transcript (dùng cho bằng chứng SOS — CHỈ TEXT, không audio) ──

  bool _isCapturing = false;
  final StringBuffer _captureBuffer = StringBuffer();

  /// Thu lại toàn bộ transcript nhận diện được trong [duration] kể từ lúc gọi.
  /// Dùng chung session STT đang chạy sẵn (không mở thêm mic session nào khác)
  /// → không có xung đột audio-focus, không cần pause/resume gì cả.
  Future<String> captureTranscript({Duration duration = const Duration(seconds: 15)}) async {
    _captureBuffer.clear();
    _isCapturing = true;
    await Future.delayed(duration);
    _isCapturing = false;
    return _captureBuffer.toString().trim();
  }

  // ─── Restart (single timer, debounced) ───────────────────────────────────

  /// Huỷ timer restart cũ, đặt timer mới.
  /// Tránh trường hợp onStatus + onError cùng schedule → error_busy.
  void _scheduleRestart(Duration delay) {
    _restartTimer?.cancel();
    _restartTimer = Timer(delay, _startSession);
  }

  // ─── Session ──────────────────────────────────────────────────────────────

  Future<void> _startSession() async {
    if (!_isMonitoring) return;
    if (_isListening) return;
    if (_isRestarting) return; // tránh concurrent restart

    _isRestarting = true;
    try {
      // Đảm bảo session cũ đã dừng hoàn toàn — mute để chặn beep "dừng nghe"
      await SystemSoundMuter.mute();
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 120));

      if (!_isMonitoring) {
        await SystemSoundMuter.unmute();
        return;
      }

      debugPrint('[VOICE] Starting session...');
      // Vẫn đang mute từ bước stop() ở trên → beep "bắt đầu nghe" cũng bị chặn luôn
      await _speech.listen(
        onResult: _onResult,
        listenFor: _listenFor,
        pauseFor: _pauseFor,
        localeId: _cachedLocaleId,
        onSoundLevelChange: onSoundLevel != null ? _onSoundLevelChange : null,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          // Không dùng dictation mode nữa — dictation cần warm-up lâu hơn
          // (đôi khi phải chờ cloud endpoint) → dễ mất mất mấy từ đầu ngay
          // lúc vừa restart, khiến cảm giác "mất thu âm". Mode mặc định
          // (confirmation) khởi động nhanh hơn, phù hợp việc restart liên tục.
        ),
      );
      _isListening = true;
      debugPrint('[VOICE] Session started OK');
      // Đợi qua thời điểm phát beep bắt đầu nghe rồi mới unmute lại — không mute
      // vĩnh viễn vì user vẫn cần nghe nhạc/thông báo khác bình thường.
      unawaited(Future.delayed(const Duration(milliseconds: 500), SystemSoundMuter.unmute));
    } catch (e) {
      debugPrint('[VOICE] _startSession error: $e');
      _isListening = false;
      await SystemSoundMuter.unmute();
      if (_isMonitoring) _scheduleRestart(const Duration(seconds: 3));
    } finally {
      _isRestarting = false;
    }
  }

  // ─── Result processing ────────────────────────────────────────────────────

  void _onResult(SpeechRecognitionResult result) {
    final transcript = result.recognizedWords.toLowerCase().trim();
    if (transcript.isEmpty) return;

    debugPrint('[VOICE] Heard: "${result.recognizedWords}" (final: ${result.finalResult})');

    if (_isCapturing && result.finalResult && result.recognizedWords.isNotEmpty) {
      _captureBuffer.write('${result.recognizedWords} ');
    }

    final now = DateTime.now();
    if (_lastDetectedAt != null && now.difference(_lastDetectedAt!) < _cooldown) return;

    // 1. Exact match
    for (final kw in keywords) {
      if (transcript.contains(kw)) {
        _fire(kw, now);
        return;
      }
    }

    // 2. Fuzzy match — bắt mishearing: "have" → "help" (dist=2)
    final words = transcript.split(RegExp(r'\s+'));
    for (final kw in _fuzzyKeywords) {
      for (final word in words) {
        if (word.length < 3) continue;
        final dist = _editDistance(word, kw);
        // threshold 2 cho mọi từ — "have"→"help" dist=2 sẽ match
        if (dist <= 2) {
          debugPrint('[VOICE] Fuzzy: "$word" ≈ "$kw" (dist=$dist)');
          _fire(kw, now);
          return;
        }
      }
    }
  }

  void _fire(String kw, DateTime now) {
    _lastDetectedAt = now;
    debugPrint('[VOICE] KEYWORD DETECTED: "$kw"');
    onKeywordDetected(kw);
  }

  void _onSoundLevelChange(double level) {
    onSoundLevel?.call((120.0 + level).clamp(0.0, 120.0));
  }

  // ─── Watchdog ────────────────────────────────────────────────────────────

  void _startWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(_watchdogInterval, (_) {
      if (!_isMonitoring) {
        _watchdogTimer?.cancel();
        return;
      }
      if (!_isListening && !_isRestarting) {
        debugPrint('[VOICE] Watchdog → restart');
        _scheduleRestart(const Duration(milliseconds: 300));
      }
    });
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Future<String?> _bestLocale() async {
    try {
      final locales = await _speech.locales();
      debugPrint('[VOICE] Locales: ${locales.map((l) => l.localeId).join(', ')}');
      return locales
          .firstWhere((l) => l.localeId.startsWith('en_US'),
              orElse: () => locales.firstWhere(
                    (l) => l.localeId.startsWith('en'),
                    orElse: () => locales.firstWhere(
                      (l) => l.localeId.startsWith('vi'),
                      orElse: () => locales.first,
                    ),
                  ))
          .localeId;
    } catch (_) {
      return null;
    }
  }

  static int _editDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (j) => j);
    var curr = List<int>.filled(b.length + 1, 0);
    for (int i = 1; i <= a.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= b.length; j++) {
        curr[j] = a[i - 1] == b[j - 1] ? prev[j - 1] : 1 + _min3(prev[j], curr[j - 1], prev[j - 1]);
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }

  static int _min3(int a, int b, int c) => a < b ? (a < c ? a : c) : (b < c ? b : c);
}
