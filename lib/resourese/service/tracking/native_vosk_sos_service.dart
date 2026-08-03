import 'package:flutter/services.dart';

/// Điều khiển VoskSosService (native Android) — service nghe từ khoá SOS
/// CHẠY VĨNH VIỄN bằng Vosk (AudioRecord liên tục, không session-timeout như
/// android.speech.SpeechRecognizer).
///
/// QUAN TRỌNG: service native này tự gửi SOS thẳng bằng HTTP, KHÔNG phụ
/// thuộc Flutter engine còn sống hay không — nên start()/stop() ở đây chỉ là
/// bật/tắt, KHÔNG cần (và không nên) dùng chung với VoiceKeywordService cũ
/// (speech_to_text) nữa, vì 2 bên cùng giành mic sẽ conflict.
///
/// [keywordEvents] chỉ để cập nhật UI theo thời gian thực khi Flutter đang
/// sống (vd hiện banner "Đã phát hiện từ khoá") — không phải đường gửi SOS
/// chính, đường chính nằm hẳn bên native.
class NativeVoskSosService {
  static const _methodChannel = MethodChannel('com.chaitany.abhay/vosk_sos');
  static const _eventChannel = EventChannel('com.chaitany.abhay/vosk_sos_events');

  static Future<void> start() async {
    try {
      await _methodChannel.invokeMethod('start');
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _methodChannel.invokeMethod('stop');
    } catch (_) {}
  }

  /// Stream sự kiện {keyword, text} mỗi khi native phát hiện từ khoá.
  static Stream<Map<String, String>> get keywordEvents => _eventChannel.receiveBroadcastStream().map(
        (event) => Map<String, String>.from(event as Map),
      );
}
