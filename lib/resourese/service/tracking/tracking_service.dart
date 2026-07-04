import 'dart:async';

import 'package:abhay_app_v2/models/request/alert/alert_request_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/resourese/home/ihome_repository.dart';
import 'package:abhay_app_v2/resourese/service/location_service.dart';
import 'package:abhay_app_v2/resourese/tracking/itracking_repository.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/utils/map_utils.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'foreground_service_manager.dart';
import 'gps_filter.dart';
import 'location_helper.dart';
import 'sudden_stop_detector.dart';
import 'voice_keyword_service.dart';

/// GetxService quản lý toàn bộ trạng thái tracking khi app foreground.
///
/// Mic strategy:
///   - VoiceKeywordService dùng speech_to_text để VỪATHU âm VỪATHU sound level
///   - record package KHÔNG dùng nữa (tránh audio focus conflict trên Android)
///   - sound.obs được update từ STT's onSoundLevelChange callback
class TrackingService extends GetxService {
  // ─── Reactive state ───────────────────────────────────────────────────────
  final RxDouble speed = 0.0.obs;
  final RxDouble sound = 0.0.obs;
  final RxString locationText = ''.obs;
  final RxBool isTracking = false.obs;
  final RxBool isOverSpeed = false.obs;
  final RxBool isOverSound = false.obs;
  final RxDouble detectedSpeedLimit = 0.0.obs;
  final Rx<String?> detectedKeyword = Rx<String?>(null);
  Position? _currentPosition;

  // ─── Internals ────────────────────────────────────────────────────────────
  late final ITrackingRepository _repo;

  StreamSubscription<Position>? _gpsSub;
  VoiceKeywordService? _voiceService;

  static const Duration _keywordAlertDuration = Duration(seconds: 12);

  final _gpsFilter = GpsFilter();
  final _suddenStop = SuddenStopDetector();
  final _locationHelper = LocationHelper();

  // ─── User settings ────────────────────────────────────────────────────────
  double _maxSpeed = 60.0;
  double _maxSound = 80.0;
  bool _isStopAlertEnabled = false;
  bool _isMeasuringSound = false;
  int _delaySeconds = 10;

  // ─── Alert cooldown ───────────────────────────────────────────────────────
  static const int _suddenStopCooldownSec = 30;
  static const int _stopAlertCooldownSec = 60;

  double _lastSpeed = 0.0;
  bool _hasSentStopAlert = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _repo = Get.find<ITrackingRepository>();
    _restoreState();
  }

  @override
  void onClose() {
    _stopInternal();
    super.onClose();
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  Future<void> start(UserModel user) async {
    if (isTracking.value) return;

    _loadSettings(user);

    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      loggerHelper.error('[TRACKING] Permission denied');
      return;
    }

    isTracking.value = true;
    await LocalStorage.setBool(SharedKey.isTracking, true);
    _cacheSettings();

    _startGps();
    _startVoice(); // voice cũng đo sound level qua STT onSoundLevelChange

    await ForegroundServiceManager.start();
    loggerHelper.success('[TRACKING] Started');
  }

  Future<void> stop() async {
    if (!isTracking.value) return;
    _stopInternal();
    isTracking.value = false;
    await LocalStorage.setBool(SharedKey.isTracking, false);
    await ForegroundServiceManager.stop();
    loggerHelper.logBlue('[TRACKING] Stopped');
  }

  void applySettings(UserModel user) {
    _loadSettings(user);
    _cacheSettings();
    // Restart voice để áp dụng _isMeasuringSound mới
    if (isTracking.value) {
      _stopVoice();
      _startVoice();
    }
  }

  void dismissKeywordAlert() => detectedKeyword.value = null;

  // ─── Private ──────────────────────────────────────────────────────────────

  void _loadSettings(UserModel user) {
    _maxSpeed = (user.maxSpeed ?? 60).toDouble();
    _maxSound = (user.maxSound ?? 80).toDouble();
    _isStopAlertEnabled = (user.isStopAlert ?? 0) == 1;
    _isMeasuringSound = (user.isMeasuringSound ?? 0) == 1;
    _delaySeconds = user.delayTimeAlert ?? 10;
  }

  void _cacheSettings() {
    LocalStorage.setInt(SharedKey.cachedMaxSpeed, _maxSpeed.toInt());
    LocalStorage.setInt(SharedKey.cachedMaxSound, _maxSound.toInt());
    LocalStorage.setInt(SharedKey.cachedDelayTimeAlert, _delaySeconds);
    LocalStorage.setBool(SharedKey.cachedIsStopAlert, _isStopAlertEnabled);
    LocalStorage.setBool(SharedKey.cachedIsMeasuringSound, _isMeasuringSound);
  }

  void _stopInternal() {
    _gpsSub?.cancel();
    _gpsSub = null;
    _stopVoice();

    speed.value = 0.0;
    sound.value = 0.0;
    locationText.value = '';
    isOverSpeed.value = false;
    isOverSound.value = false;
    detectedKeyword.value = null;

    _gpsFilter.reset();
    _suddenStop.reset();
    _locationHelper.reset();
    _lastSpeed = 0.0;
    _hasSentStopAlert = false;
  }

  void _restoreState() {
    final wasTracking = LocalStorage.getBool(SharedKey.isTracking);
    if (wasTracking) {
      isTracking.value = true;
      loggerHelper.logBlue('[TRACKING] Restored tracking flag from storage');
    }
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
      onError: (e) => loggerHelper.error('[GPS] Stream error: $e'),
      cancelOnError: false,
    );
  }

  Future<void> _onPosition(Position position) async {
    _currentPosition = position;

    final result = _gpsFilter.filter(position);
    if (result == null) return;

    final speedKmh = result.speedKmh;
    speed.value = speedKmh;
    isOverSpeed.value = speedKmh > _maxSpeed && speedKmh > 5;

    final address = await _locationHelper.getAddress(position);
    if (address.isNotEmpty) locationText.value = address;

    await _checkOverSpeedAlert(speedKmh, position);
    await _checkSuddenStopAlert(speedKmh, position);
    await _checkStopAlert(speedKmh, position);

    _lastSpeed = speedKmh;
  }

  // ─── Voice + Sound (dùng chung mic qua STT) ──────────────────────────────

  void _startVoice() {
    _voiceService = VoiceKeywordService(
      onKeywordDetected: _onKeywordDetected,
      // Sound level từ STT audio stream — không cần record package riêng
      onSoundLevel: _isMeasuringSound ? _onSoundLevel : null,
    );
    _voiceService!.startMonitoring();
  }

  void _stopVoice() {
    _voiceService?.stopMonitoring();
    _voiceService = null;
  }

  void _onSoundLevel(double dba) {
    sound.value = dba;
    isOverSound.value = dba > _maxSound;
  }

  void _onKeywordDetected(String keyword) async {
    detectedKeyword.value = keyword;
    loggerHelper.logBlue('[VOICE] Detected: "$keyword"');

    final IHomeRepository homeRepository = Get.find<IHomeRepository>();

    if ((_currentPosition?.latitude ?? 0) == 0 || (_currentPosition?.longitude ?? 0) == 0) {
      final position = await LocationService.to.getPosition();

      if (position == null) {
        DialogUtils.showErrorDialog('Unable to get current location. Please ensure location services are enabled.');
        return;
      }

      final fullAddress = await MapUtils.getAddressFromPosition(position);
      await homeRepository.onSosSend(
        latitude: position.latitude,
        longitude: position.longitude,
        address: fullAddress.fullAddress.isNotEmpty
            ? fullAddress.fullAddress
            : locationText.value.isNotEmpty
                ? locationText.value
                : '${position.latitude}, ${position.longitude}',
      );
      return;
    }

    await homeRepository.onSosSend(
      latitude: _currentPosition?.latitude ?? 0.0,
      longitude: _currentPosition?.longitude ?? 0.0,
      address: locationText.value,
      content: '[VOICE] Detected: "$keyword"',
    );

    Future.delayed(_keywordAlertDuration, () {
      if (detectedKeyword.value == keyword) detectedKeyword.value = null;
    });
  }

  // ─── Alert logic ─────────────────────────────────────────────────────────

  Future<void> _checkOverSpeedAlert(double speedKmh, Position pos) async {
    if (speedKmh <= _maxSpeed || speedKmh <= 15) return;
    if (!_canSendAlert(SharedKey.lastSpeedAlertAt, _delaySeconds)) return;
    _markAlertSent(SharedKey.lastSpeedAlertAt);
    await _send(type: 2, speedKmh: speedKmh, position: pos);
  }

  Future<void> _checkSuddenStopAlert(double speedKmh, Position pos) async {
    if (!_isStopAlertEnabled) return;
    if (!_suddenStop.detect(speedKmh)) return;
    if (!_canSendAlert(SharedKey.lastSuddenStopAlertAt, _suddenStopCooldownSec)) return;
    _markAlertSent(SharedKey.lastSuddenStopAlertAt);
    await _send(type: 3, speedKmh: speedKmh, position: pos);
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
    await _send(type: 4, speedKmh: 0, position: pos);
  }

  Future<void> _send({
    required int type,
    required double speedKmh,
    required Position position,
  }) async {
    final address = await LocationHelper.geocode(position.latitude, position.longitude);
    final params = AlertRequestModel(
      type: type,
      location: address,
      lat: position.latitude,
      lng: position.longitude,
      speed: speedKmh,
      sound: _isMeasuringSound ? sound.value : 0,
      speedLimit: _maxSpeed.toInt(),
    );
    final ok = await _repo.sendAlert(params);
    if (!ok) loggerHelper.error('[TRACKING] Alert type=$type failed');
  }

  // ─── Cooldown helpers ─────────────────────────────────────────────────────

  bool _canSendAlert(String key, int cooldownSec) {
    final lastMs = LocalStorage.getInt(key);
    if (lastMs == 0) return true;
    return DateTime.now().millisecondsSinceEpoch - lastMs >= cooldownSec * 1000;
  }

  void _markAlertSent(String key) {
    LocalStorage.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }

  // ─── Permissions ──────────────────────────────────────────────────────────

  static Future<bool> _requestPermissions() async {
    var loc = await Permission.location.status;
    if (!loc.isGranted) loc = await Permission.location.request();
    if (!loc.isGranted) return false;

    var bgLoc = await Permission.locationAlways.status;
    if (!bgLoc.isGranted) bgLoc = await Permission.locationAlways.request();

    final mic = await Permission.microphone.status;
    if (!mic.isGranted) await Permission.microphone.request();

    return true;
  }

  static Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// Toggle sound nhanh từ Home — không đợi Settings save
  void setSoundEnabled(bool enabled) {
    _isMeasuringSound = enabled;
    LocalStorage.setBool(SharedKey.cachedIsMeasuringSound, enabled);
    if (isTracking.value) {
      _stopVoice();
      _startVoice(); // restart với onSoundLevel mới
    }
    if (!enabled) {
      sound.value = 0.0;
      isOverSound.value = false;
    }
  }
}
