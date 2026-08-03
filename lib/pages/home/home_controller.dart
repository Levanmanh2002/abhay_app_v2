import 'dart:async';

import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/models/response/traffic/road_ahead_model.dart';
import 'package:abhay_app_v2/resourese/home/ihome_repository.dart';
import 'package:abhay_app_v2/resourese/service/location_service.dart';
import 'package:abhay_app_v2/resourese/service/tracking/tracking_service.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/easyloading_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final IHomeRepository homeRepository;

  HomeController({required this.homeRepository});

  late final TrackingService _trackingService;

  StreamSubscription<RoadAnnouncement>? _roadSub;

  RxDouble get speed => _trackingService.speed;
  RxDouble get sound => _trackingService.sound;
  RxString get locationText => _trackingService.locationText;
  RxBool get isTracking => _trackingService.isTracking;
  RxBool get isOverSpeed => _trackingService.isOverSpeed;
  RxBool get isOverSound => _trackingService.isOverSound;

  Rx<String?> get detectedKeyword => _trackingService.detectedKeyword;

  /// Dữ liệu đường phía trước từ TomTom Snap to Roads.
  /// Dùng cho panel "biển báo sắp tới" trên Home nếu cần hiển thị.
  Rx<RoadAheadResult?> get roadAhead => _trackingService.roadAhead;

  /// Thông báo đường bộ gần nhất — giữ lại để UI có thể render banner thay vì
  /// toast, nếu sau này muốn đổi cách hiển thị.
  final Rx<RoadAnnouncement?> lastAnnouncement = Rx<RoadAnnouncement?>(null);

  void dismissKeywordAlert() => _trackingService.dismissKeywordAlert();

  var maxSpeed = 60.0.obs;

  var isTogglingTracking = false.obs;
  var isSoundEnabled = false.obs;

  /// Giới hạn tốc độ ĐANG áp dụng để hiển thị lên gauge:
  /// - Nếu auto-detect bật và TomTom đã trả về speed limit hợp lệ (>0) → dùng giá trị TomTom
  /// - Ngược lại → dùng maxSpeed user tự cấu hình trong Settings
  /// Đọc trực tiếp .value của cả 2 nguồn (không bọc qua object khác) để Obx
  /// track được reactivity đúng, dù kết quả cuối lấy từ nguồn nào.
  double get effectiveLimit {
    final detected = _trackingService.detectedSpeedLimit.value;
    return detected > 0 ? detected : maxSpeed.value;
  }

  /// true nếu limit đang hiển thị là lấy từ biển báo TomTom (không phải user tự set)
  bool get isLimitFromRoadSign => _trackingService.detectedSpeedLimit.value > 0;

  @override
  void onInit() {
    super.onInit();
    _trackingService = Get.find<TrackingService>();
    _listenRoadAnnouncements();
  }

  @override
  void onClose() {
    _roadSub?.cancel();
    _roadSub = null;
    super.onClose();
  }

  /// TrackingService không còn tự gọi DialogUtils nữa — nó phát sự kiện, UI
  /// quyết định cách hiển thị. Ở đây dùng info dialog cho đơn giản; khuyến nghị
  /// đổi sang banner không chặn hoặc TTS vì người dùng đang lái xe.
  void _listenRoadAnnouncements() {
    _roadSub?.cancel();
    _roadSub = _trackingService.announcements.listen(
      (a) {
        lastAnnouncement.value = a;
        DialogUtils.showInfoDialog(a.message);
      },
      onError: (e) => loggerHelper.error('[HOME] Road announcement error: $e'),
    );
  }

  Future<void> onToggleTracking(UserModel? user) async {
    if (isTogglingTracking.value) return;

    if (user == null) {
      DialogUtils.showErrorDialog('Cannot start tracking: user data not loaded');
      return;
    }

    isTogglingTracking.value = true;
    try {
      // Dừng khi GPS đang thực sự chạy HOẶC cờ tracking đang bật (tránh kẹt ở
      // trạng thái cờ bật nhưng GPS chưa chạy — bấm 1 lần không tắt được).
      if (_trackingService.isGpsRunning) {
        await _trackingService.stop();
      } else if (isTracking.value) {
        // Cờ bật nhưng GPS chưa chạy → khôi phục lại thay vì tắt.
        await _startTracking(user);
      } else {
        await _startTracking(user);
      }
    } catch (e, st) {
      loggerHelper.error('[HOME] Toggle tracking error: $e', stackTrace: st);
      DialogUtils.showErrorDialog('Tracking error. Please try again.');
    } finally {
      isTogglingTracking.value = false;
    }
  }

  Future<void> _startTracking(UserModel user) async {
    final gpsEnabled = await TrackingService.isLocationServiceEnabled();
    if (!gpsEnabled) {
      DialogUtils.showErrorDialog('Please enable location services to start tracking');
      return;
    }
    maxSpeed.value = (user.maxSpeed ?? 60).toDouble();
    await _trackingService.start(user);
  }

  /// Gọi khi ProfileController load xong user → apply settings + auto-resume.
  ///
  /// Trước đây auto-resume không bao giờ chạy: TrackingService._restoreState()
  /// đã set isTracking = true, còn start() lại thoát sớm khi thấy cờ đó bật.
  /// Nay start() kiểm tra isGpsRunning nên nhánh này hoạt động đúng.
  Future<void> onUserLoaded(UserModel user) async {
    maxSpeed.value = (user.maxSpeed ?? 60).toDouble();
    isSoundEnabled.value = (user.isMeasuringSound ?? 0) == 1;

    if (isTracking.value && !_trackingService.isGpsRunning) {
      loggerHelper.logBlue('[HOME] Auto-resuming tracking after app restart');
      await _trackingService.start(user);
    } else {
      // Không tracking → vẫn đồng bộ settings để lần start sau dùng giá trị mới.
      _trackingService.applySettings(user);
    }
  }

  /// Gọi khi user thay đổi settings
  void onSettingsChanged(UserModel user) {
    maxSpeed.value = (user.maxSpeed ?? 60).toDouble();
    isSoundEnabled.value = (user.isMeasuringSound ?? 0) == 1;
    _trackingService.applySettings(user);
  }

  void onSosTrigger() async {
    try {
      showEasyLoading();
      final position = await LocationService.to.getPosition();

      if (position == null) {
        DialogUtils.showErrorDialog('Unable to get current location. Please ensure location services are enabled.');
        return;
      }
      await homeRepository.onSosSend(
        latitude: position.latitude,
        longitude: position.longitude,
        address: _trackingService.locationText.value,
      );
    } catch (e, st) {
      loggerHelper.error('[HOME] SOS trigger error: $e', stackTrace: st);
      DialogUtils.showErrorDialog('Failed to trigger SOS. Please try again.');
    } finally {
      dismissEasyLoading();
    }
  }

  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    _trackingService.setSoundEnabled(isSoundEnabled.value);
  }
}
