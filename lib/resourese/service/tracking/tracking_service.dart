import 'dart:async';

import 'package:abhay_app_v2/models/request/alert/alert_request_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/models/response/traffic/road_ahead_model.dart';
import 'package:abhay_app_v2/resourese/service/map/tom_tom_service.dart';
import 'package:abhay_app_v2/resourese/tracking/itracking_repository.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'foreground_service_manager.dart';
import 'gps_filter.dart';
import 'location_helper.dart';
import 'native_vosk_sos_service.dart';
import 'sudden_stop_detector.dart';

/// Loại thông báo đường bộ phát ra cho tầng UI.
enum RoadAnnouncementType { currentSpeedLimit, upcomingSpeedLimit, trafficSign, restriction }

/// Sự kiện một lần, để UI hiển thị toast/banner.
///
/// Service KHÔNG tự gọi DialogUtils nữa — bản cũ làm vậy khiến tầng data điều
/// khiển UI, và spam dialog khi đi qua nhiều đoạn đường liên tiếp. Giờ UI
/// (HomeController / MapAppController) tự lắng nghe [TrackingService.announcements]
/// và quyết định hiển thị thế nào, có thể debounce hoặc chuyển sang TTS.
class RoadAnnouncement {
  final RoadAnnouncementType type;
  final String message;
  final double? distanceM;

  const RoadAnnouncement({required this.type, required this.message, this.distanceM});

  @override
  String toString() => '[$type] $message';
}

/// GetxService quản lý toàn bộ trạng thái tracking khi app foreground.
///
/// Mic strategy:
///   - Nghe từ khoá SOS: VoskSosService (native, Vosk) — chạy vĩnh viễn,
///     không ngắt/connect lại như android.speech.SpeechRecognizer, và gửi
///     SOS trực tiếp bằng HTTP, độc lập hoàn toàn Flutter isolate.
///   - VoiceKeywordService (speech_to_text) không còn dùng cho việc nghe
///     từ khoá nữa (giữ file lại phòng cần dùng việc khác) — vì 1 mic không
///     dùng đồng thời cho 2 audio consumer khác nhau được.
///   - Đo âm thanh môi trường (isMeasuringSound) tạm ngưng vì lý do trên —
///     xem TODO trong setSoundEnabled().
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

  /// Dữ liệu đường phía trước từ TomTom Snap to Roads: giới hạn tốc độ hiện tại,
  /// giới hạn sắp thay đổi, biển báo phía trước, hạn chế theo loại xe.
  final Rx<RoadAheadResult?> roadAhead = Rx<RoadAheadResult?>(null);

  /// Stream sự kiện một lần cho UI. Broadcast — nhiều màn hình cùng nghe được.
  final _announcementCtrl = StreamController<RoadAnnouncement>.broadcast();
  Stream<RoadAnnouncement> get announcements => _announcementCtrl.stream;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // ─── Internals ────────────────────────────────────────────────────────────
  late final ITrackingRepository _repo;

  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<Map<String, String>>? _nativeKeywordSub;

  static const Duration _keywordAlertDuration = Duration(seconds: 12);

  final _gpsFilter = GpsFilter();
  final _suddenStop = SuddenStopDetector();
  final _locationHelper = LocationHelper();
  final _tomtomSvc = TomTomService();

  /// TRUE khi GPS stream thực sự đang chạy. Tách khỏi [isTracking] vì
  /// [isTracking] còn được khôi phục từ storage lúc khởi động app (khi đó cờ
  /// bật nhưng GPS chưa chạy).
  bool get isGpsRunning => _gpsSub != null;

  // ─── User settings ────────────────────────────────────────────────────────
  double _maxSpeed = 60.0;
  double _maxSound = 80.0;
  bool _isStopAlertEnabled = false;
  bool _isMeasuringSound = false;
  bool _isAutoDetectSpeedLimit = false;
  int _delaySeconds = 10;

  // TomTom detected speed limit (0 = chưa có)
  double _tomtomSpeedLimit = 0.0;

  // Chống lặp thông báo
  double _lastAnnouncedCurrentLimit = 0.0;
  double _lastAnnouncedNextLimit = 0.0;
  final Map<String, DateTime> _lastAnnouncedSignAt = {};

  bool _isFetchingRoadInfo = false;

  // ─── Ngưỡng gọi TomTom ────────────────────────────────────────────────────
  /// Không gọi API khi đi quá chậm — vừa tiết kiệm quota, vừa vì heading GPS
  /// dưới ngưỡng này quá nhiễu để suy ra hướng đi.
  static const double _tomtomMinSpeedKmh = 15.0;

  /// Chỉ nhắc biển báo khi còn cách dưới ngưỡng này.
  static const double _signAnnounceRadiusM = 300.0;

  /// Cùng một loại biển báo không nhắc lại trong khoảng thời gian này.
  static const Duration _signAnnounceCooldown = Duration(seconds: 90);

  // ─── Alert cooldown ───────────────────────────────────────────────────────
  static const int _suddenStopCooldownSec = 30;
  static const int _stopAlertCooldownSec = 60;
  static const int _speedAlertCooldownSec = 300;

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
    _announcementCtrl.close();
    super.onClose();
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// FIX: điều kiện thoát sớm trước đây là `if (isTracking.value) return;`.
  /// Sau khi app bị kill và mở lại, [_restoreState] đã set isTracking = true,
  /// nên lời gọi start() từ HomeController.onUserLoaded() thoát ngay lập tức →
  /// GPS stream KHÔNG BAO GIỜ khởi động, UI hiển thị "đang tracking" trong khi
  /// thực tế không thu thập gì. Giờ kiểm tra trạng thái chạy thật (isGpsRunning).
  Future<void> start(UserModel user) async {
    if (isGpsRunning) {
      // Vẫn cập nhật settings phòng khi user đổi cấu hình rồi gọi lại start().
      _loadSettings(user);
      _cacheSettings();
      return;
    }

    _loadSettings(user);

    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      loggerHelper.error('[TRACKING] Permission denied');
      isTracking.value = false;
      await LocalStorage.setBool(SharedKey.isTracking, false);
      return;
    }

    isTracking.value = true;
    await LocalStorage.setBool(SharedKey.isTracking, true);
    _cacheSettings();

    _startGps();

    await NativeVoskSosService.start();
    _listenNativeKeywordEvents();
    if (_isMeasuringSound) {
      loggerHelper.logBlue('[TRACKING] Sound metering tạm tắt — đang dùng chung mic với Vosk SOS listener');
      sound.value = 0;
      isOverSound.value = false;
    }

    await ForegroundServiceManager.start();
    loggerHelper.success('[TRACKING] Started');
  }

  Future<void> stop() async {
    if (!isTracking.value && !isGpsRunning) return;
    _stopInternal();
    isTracking.value = false;
    await LocalStorage.setBool(SharedKey.isTracking, false);
    await ForegroundServiceManager.stop();
    loggerHelper.logBlue('[TRACKING] Stopped');
  }

  void applySettings(UserModel user) {
    _loadSettings(user);
    _cacheSettings();
    // Tắt auto-detect → xoá dữ liệu TomTom đang hiển thị để UI không giữ giá
    // trị cũ mãi mãi.
    if (!_isAutoDetectSpeedLimit) {
      _tomtomSvc.reset();
      _tomtomSpeedLimit = 0.0;
      detectedSpeedLimit.value = 0.0;
      roadAhead.value = null;
    }
  }

  void dismissKeywordAlert() => detectedKeyword.value = null;

  /// Lắng nghe event từ VoskSosService (native) chỉ để cập nhật UI real-time.
  /// Việc gửi SOS thật sự đã được native tự làm độc lập.
  void _listenNativeKeywordEvents() {
    _nativeKeywordSub?.cancel();
    _nativeKeywordSub = NativeVoskSosService.keywordEvents.listen((event) {
      final keyword = event['keyword'] ?? '';
      if (keyword.isEmpty) return;
      detectedKeyword.value = keyword;
      Future.delayed(_keywordAlertDuration, () {
        if (detectedKeyword.value == keyword) detectedKeyword.value = null;
      });
    });
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  void _loadSettings(UserModel user) {
    _maxSpeed = (user.maxSpeed ?? 60).toDouble();
    _maxSound = (user.maxSound ?? 80).toDouble();
    _isStopAlertEnabled = (user.isStopAlert ?? 0) == 1;
    _isMeasuringSound = (user.isMeasuringSound ?? 0) == 1;
    _isAutoDetectSpeedLimit = (user.isAutoDetectSpeedLimit ?? 0) == 1;
    _delaySeconds = user.delayTimeAlert ?? 10;
  }

  void _cacheSettings() {
    LocalStorage.setInt(SharedKey.cachedMaxSpeed, _maxSpeed.toInt());
    LocalStorage.setInt(SharedKey.cachedMaxSound, _maxSound.toInt());
    LocalStorage.setInt(SharedKey.cachedDelayTimeAlert, _delaySeconds);
    LocalStorage.setBool(SharedKey.cachedIsStopAlert, _isStopAlertEnabled);
    LocalStorage.setBool(SharedKey.cachedIsMeasuringSound, _isMeasuringSound);
    LocalStorage.setBool(SharedKey.cachedIsAutoDetectSpeedLimit, _isAutoDetectSpeedLimit);
  }

  void _stopInternal() {
    _gpsSub?.cancel();
    _gpsSub = null;
    NativeVoskSosService.stop();
    _nativeKeywordSub?.cancel();
    _nativeKeywordSub = null;

    speed.value = 0.0;
    sound.value = 0.0;
    locationText.value = '';
    isOverSpeed.value = false;
    isOverSound.value = false;
    detectedKeyword.value = null;
    roadAhead.value = null;

    _gpsFilter.reset();
    _suddenStop.reset();
    _locationHelper.reset();
    _tomtomSvc.reset();

    _lastSpeed = 0.0;
    _hasSentStopAlert = false;
    _tomtomSpeedLimit = 0.0;
    _lastAnnouncedCurrentLimit = 0.0;
    _lastAnnouncedNextLimit = 0.0;
    _lastAnnouncedSignAt.clear();
    _isFetchingRoadInfo = false;
    detectedSpeedLimit.value = 0.0;
  }

  void _restoreState() {
    final wasTracking = LocalStorage.getBool(SharedKey.isTracking);
    if (wasTracking) {
      isTracking.value = true;
      loggerHelper.logBlue('[TRACKING] Restored tracking flag from storage — chờ user load để start GPS');
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

    // TomTom chạy song song, KHÔNG chặn luồng cảnh báo. Bản cũ await ngay tại
    // đây với timeout 8s × 2 request, làm trễ toàn bộ logic phát hiện tai nạn.
    if (_isAutoDetectSpeedLimit && speedKmh >= _tomtomMinSpeedKmh) {
      unawaited(_updateRoadInfo(position, speedKmh));
    }

    final effectiveLimit = _effectiveLimit();
    isOverSpeed.value = speedKmh > effectiveLimit && speedKmh > 5;

    final address = await _locationHelper.getAddress(position);
    if (address.isNotEmpty) locationText.value = address;

    await _checkOverSpeedAlert(speedKmh, position);
    await _checkSuddenStopAlert(speedKmh, position);
    await _checkStopAlert(speedKmh, position);

    _lastSpeed = speedKmh;
  }

  double _effectiveLimit() => (_isAutoDetectSpeedLimit && _tomtomSpeedLimit > 0) ? _tomtomSpeedLimit : _maxSpeed;

  // ─── TomTom Snap to Roads ─────────────────────────────────────────────────

  /// 1 request duy nhất trả về: giới hạn tốc độ đoạn đang đi, giới hạn sắp
  /// thay đổi, biển báo phía trước, hạn chế theo loại xe.
  Future<void> _updateRoadInfo(Position position, double speedKmh) async {
    if (_isFetchingRoadInfo) return;
    _isFetchingRoadInfo = true;
    try {
      final road = await _tomtomSvc.update(
        lat: position.latitude,
        lng: position.longitude,
        headingDeg: position.heading,
        speedKmh: speedKmh,
        timestamp: position.timestamp,
      );
      if (road == null) return;

      roadAhead.value = road;

      if (road.currentSpeedLimitKmh > 0) {
        _tomtomSpeedLimit = road.currentSpeedLimitKmh;
        detectedSpeedLimit.value = road.currentSpeedLimitKmh;
      }

      _emitAnnouncements(road);
    } catch (e, st) {
      loggerHelper.error('[TRACKING] Road info error: $e', stackTrace: st);
    } finally {
      _isFetchingRoadInfo = false;
    }
  }

  void _emitAnnouncements(RoadAheadResult road) {
    // 1. Vào đoạn đường có giới hạn tốc độ mới
    final current = road.currentSpeedLimitKmh;
    if (current > 0 && current != _lastAnnouncedCurrentLimit) {
      _lastAnnouncedCurrentLimit = current;
      final where = road.roadName?.isNotEmpty == true ? '${road.roadName}: ' : '';
      _emit(RoadAnnouncement(
        type: RoadAnnouncementType.currentSpeedLimit,
        message: '${where}giới hạn tốc độ ${current.toInt()} km/h',
      ));
    }

    // 2. Giới hạn tốc độ sắp thay đổi
    final next = road.nextSpeedLimit;
    if (next != null && next.valueKmh != _lastAnnouncedNextLimit && next.valueKmh != current) {
      _lastAnnouncedNextLimit = next.valueKmh;
      _emit(RoadAnnouncement(
        type: RoadAnnouncementType.upcomingSpeedLimit,
        message: 'Sắp tới (${next.distanceM.toInt()}m): giới hạn ${next.valueKmh.toInt()} km/h',
        distanceM: next.distanceM,
      ));
    }

    // 3. Biển báo phía trước — ưu tiên biển cảnh báo nguy hiểm, có cooldown
    //    theo từng loại để không nhắc dồn dập cùng một biển.
    final now = DateTime.now();
    for (final sign in road.signsAhead) {
      if (sign.distanceM > _signAnnounceRadiusM) break; // list đã sort tăng dần
      final last = _lastAnnouncedSignAt[sign.signType];
      if (last != null && now.difference(last) < _signAnnounceCooldown) continue;
      _lastAnnouncedSignAt[sign.signType] = now;
      _emit(RoadAnnouncement(
        type: RoadAnnouncementType.trafficSign,
        message: '${sign.label} — còn ${sign.distanceM.toInt()}m',
        distanceM: sign.distanceM,
      ));
    }

    // 4. Hạn chế theo loại xe / phát thải (biển cấm)
    for (final r in road.restrictionsAhead) {
      if (r.distanceM > _signAnnounceRadiusM) continue;
      final key = 'restriction_${r.restrictionType}_${r.engineTypes.join(",")}';
      final last = _lastAnnouncedSignAt[key];
      if (last != null && now.difference(last) < _signAnnounceCooldown) continue;
      _lastAnnouncedSignAt[key] = now;
      _emit(RoadAnnouncement(
        type: RoadAnnouncementType.restriction,
        message: '${r.label} — còn ${r.distanceM.toInt()}m',
        distanceM: r.distanceM,
      ));
    }
  }

  void _emit(RoadAnnouncement a) {
    if (_announcementCtrl.isClosed) return;
    loggerHelper.logBlue('[ROAD] $a');
    _announcementCtrl.add(a);
  }

  // ─── Alert logic ─────────────────────────────────────────────────────────

  Future<void> _checkOverSpeedAlert(double speedKmh, Position pos) async {
    final effectiveLimit = _effectiveLimit();

    if (speedKmh <= effectiveLimit || speedKmh <= 15) return;
    if (!_canSendAlert(SharedKey.lastSpeedAlertAt, _speedAlertCooldownSec)) return;
    _markAlertSent(SharedKey.lastSpeedAlertAt);
    await _send(type: 2, speedKmh: speedKmh, position: pos, speedLimit: effectiveLimit);
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
    double? speedLimit,
  }) async {
    final address = await LocationHelper.geocode(position.latitude, position.longitude);
    final locationStr = address.isNotEmpty
        ? address
        : '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    final limit = speedLimit ?? _maxSpeed;
    final params = AlertRequestModel(
      type: type,
      location: locationStr,
      lat: position.latitude,
      lng: position.longitude,
      speed: speedKmh,
      sound: _isMeasuringSound ? sound.value : 0,
      speedLimit: limit.toInt(),
    );
    final ok = await _repo.sendAlert(params);
    if (!ok) {
      loggerHelper.error('[TRACKING] Alert type=$type failed');
    } else {
      loggerHelper.success(
        '[TRACKING] Alert type=$type sent (limit=${limit.toInt()} km/h, speed=${speedKmh.toStringAsFixed(1)})',
      );
    }
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

  /// Toggle sound nhanh từ Home — không đợi Settings save.
  /// TODO: đo âm thanh môi trường hiện KHÔNG hoạt động — mic do VoskSosService
  /// (native) độc quyền giữ cho việc nghe từ khoá SOS chạy vĩnh viễn, không thể
  /// mở thêm audio consumer thứ hai song song. Cần quyết định: bỏ hẳn tính năng,
  /// hoặc tính amplitude ngay trong VoskSosService rồi bắn qua EventChannel.
  /// Chừng nào chưa quyết, toggle này chỉ đổi cờ chứ không đo được gì.
  void setSoundEnabled(bool enabled) {
    _isMeasuringSound = enabled;
    LocalStorage.setBool(SharedKey.cachedIsMeasuringSound, enabled);
    sound.value = 0.0;
    isOverSound.value = false;
  }
}
