import 'dart:async';

import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'gps_filter.dart';
import 'location_helper.dart';
import 'sudden_stop_detector.dart';

/// Entry point cho flutter_foreground_task.
/// Chạy trong background isolate khi app bị kill hoặc minimize.
@pragma('vm:entry-point')
void trackingTaskCallback() {
  FlutterForegroundTask.setTaskHandler(BackgroundTaskHandler());
}

class BackgroundTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _gpsSub;

  final _gpsFilter = GpsFilter();
  final _suddenStop = SuddenStopDetector();

  Position? _lastPosition;
  double _lastSpeed = 0.0;
  bool _hasSentStopAlert = false;

  // Settings (đọc từ SharedPreferences)
  double _maxSpeed = 60.0;
  double _maxSound = 80.0;
  bool _isStopAlertEnabled = false;
  int _delaySeconds = 10;

  static const int _suddenStopCooldownSec = 30;
  static const int _stopAlertCooldownSec = 60;

  // ─── TaskHandler lifecycle ────────────────────────────────────────────────

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Re-init dependencies (background isolate không có main() context)
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}
    await LocalStorage.init();

    _loadSettings();
    loggerHelper.logBlue('[BG] Background task started');

    _startGps();
  }

  /// Được gọi theo interval đặt trong ForegroundTaskOptions (mỗi 1s Android, 2s iOS).
  /// Dùng để cập nhật notification và đọc lại settings nếu cần.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Reload settings (user có thể đã thay đổi trong khi app đang chạy)
    _loadSettings();

    final speed = _lastPosition != null ? (_gpsFilter.filter(_lastPosition!)?.speedKmh ?? _lastSpeed) : 0.0;

    final speedStr = speed.toStringAsFixed(0);
    FlutterForegroundTask.updateService(
      notificationTitle: 'Tracking active',
      notificationText: 'Speed: $speedStr km/h | Limit: ${_maxSpeed.toInt()} km/h',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await _gpsSub?.cancel();
    _gpsSub = null;
    loggerHelper.logBlue('[BG] Background task destroyed');
  }

  // ─── GPS ──────────────────────────────────────────────────────────────────

  void _startGps() {
    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen(
      _onPosition,
      onError: (e) => loggerHelper.error('[BG GPS] Error: $e'),
      cancelOnError: false,
    );
  }

  Future<void> _onPosition(Position position) async {
    final result = _gpsFilter.filter(position);
    if (result == null) return;

    final speedKmh = result.speedKmh;
    _lastPosition = position;

    await _checkOverSpeedAlert(speedKmh, position);
    await _checkSuddenStopAlert(speedKmh, position);
    await _checkStopAlert(speedKmh, position);

    _lastSpeed = speedKmh;
  }

  // ─── Alert logic (mirrors TrackingService) ────────────────────────────────

  Future<void> _checkOverSpeedAlert(double speedKmh, Position pos) async {
    if (speedKmh <= _maxSpeed || speedKmh <= 15) return;
    if (!_canSendAlert(SharedKey.lastSpeedAlertAt, _delaySeconds)) return;

    _markAlertSent(SharedKey.lastSpeedAlertAt);
    await _sendAlert(type: 2, speedKmh: speedKmh, position: pos);
  }

  Future<void> _checkSuddenStopAlert(double speedKmh, Position pos) async {
    if (!_isStopAlertEnabled) return;
    if (!_suddenStop.detect(speedKmh)) return;
    if (!_canSendAlert(SharedKey.lastSuddenStopAlertAt, _suddenStopCooldownSec)) {
      return;
    }
    _markAlertSent(SharedKey.lastSuddenStopAlertAt);
    await _sendAlert(type: 3, speedKmh: speedKmh, position: pos);
  }

  Future<void> _checkStopAlert(double speedKmh, Position pos) async {
    final justStopped = speedKmh <= 0 && _lastSpeed > 5;
    if (!justStopped) {
      if (speedKmh > 5) _hasSentStopAlert = false;
      return;
    }
    if (_hasSentStopAlert) return;
    if (!_canSendAlert(SharedKey.lastStopAlertAt, _stopAlertCooldownSec)) return;

    _hasSentStopAlert = true;
    _markAlertSent(SharedKey.lastStopAlertAt);
    await _sendAlert(type: 4, speedKmh: 0, position: pos);
  }

  // ─── HTTP trực tiếp (không dùng GetX trong background isolate) ────────────

  Future<void> _sendAlert({
    required int type,
    required double speedKmh,
    required Position position,
  }) async {
    try {
      final token = LocalStorage.getString(SharedKey.token);
      final baseUrl = AppConstants.baseUrl;
      final apiKey = AppConstants.apiKey;

      final address = await LocationHelper.geocode(
        position.latitude,
        position.longitude,
      );

      final uri = Uri.parse('$baseUrl${AppConstants.sendAlertUri}');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        'X-TOKEN-ACCESS': apiKey,
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll({
        'type': type.toString(),
        'location': address,
        'lat': position.latitude.toString(),
        'lng': position.longitude.toString(),
        'speed': speedKmh.toString(),
        'sound': '0',
        'speed_limit': _maxSpeed.toInt().toString(),
      });

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        loggerHelper.success('[BG] Alert type=$type sent ✅');
      } else {
        loggerHelper.error('[BG] Alert type=$type failed: ${response.body}');
      }
    } catch (e) {
      loggerHelper.error('[BG] Alert send error: $e');
    }
  }

  // ─── Settings & cooldown helpers ──────────────────────────────────────────

  void _loadSettings() {
    _maxSpeed = LocalStorage.getInt(SharedKey.cachedMaxSpeed).toDouble();
    if (_maxSpeed <= 0) _maxSpeed = 60.0;

    _maxSound = LocalStorage.getInt(SharedKey.cachedMaxSound).toDouble();
    if (_maxSound <= 0) _maxSound = 80.0;

    _delaySeconds = LocalStorage.getInt(SharedKey.cachedDelayTimeAlert);
    if (_delaySeconds <= 0) _delaySeconds = 10;

    _isStopAlertEnabled = LocalStorage.getBool(SharedKey.cachedIsStopAlert);
  }

  bool _canSendAlert(String key, int cooldownSec) {
    final lastMs = LocalStorage.getInt(key);
    if (lastMs == 0) return true;
    return DateTime.now().millisecondsSinceEpoch - lastMs >= cooldownSec * 1000;
  }

  void _markAlertSent(String key) {
    LocalStorage.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }
}
