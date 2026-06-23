import 'package:abhay_app_v2/models/response/profile/user_model.dart';
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

  RxDouble get speed => _trackingService.speed;
  RxDouble get sound => _trackingService.sound;
  RxString get locationText => _trackingService.locationText;
  RxBool get isTracking => _trackingService.isTracking;
  RxBool get isOverSpeed => _trackingService.isOverSpeed;
  RxBool get isOverSound => _trackingService.isOverSound;

  Rx<String?> get detectedKeyword => _trackingService.detectedKeyword;

  void dismissKeywordAlert() => _trackingService.dismissKeywordAlert();

  var maxSpeed = 60.0.obs;

  var isTogglingTracking = false.obs;

  @override
  void onInit() {
    super.onInit();
    _trackingService = Get.find<TrackingService>();
  }

  Future<void> onToggleTracking(UserModel? user) async {
    if (isTogglingTracking.value) return;

    if (user == null) {
      DialogUtils.showErrorDialog('Cannot start tracking: user data not loaded');
      return;
    }

    isTogglingTracking.value = true;
    try {
      if (isTracking.value) {
        await _trackingService.stop();
      } else {
        final gpsEnabled = await TrackingService.isLocationServiceEnabled();
        if (!gpsEnabled) {
          DialogUtils.showErrorDialog(
            'Please enable location services to start tracking',
          );
          return;
        }
        maxSpeed.value = (user.maxSpeed ?? 60).toDouble();
        await _trackingService.start(user);
      }
    } catch (e, st) {
      loggerHelper.error('[HOME] Toggle tracking error: $e', stackTrace: st);
      DialogUtils.showErrorDialog('Tracking error. Please try again.');
    } finally {
      isTogglingTracking.value = false;
    }
  }

  /// Gọi khi ProfileController load xong user → apply settings + auto-resume
  Future<void> onUserLoaded(UserModel user) async {
    maxSpeed.value = (user.maxSpeed ?? 60).toDouble();

    if (isTracking.value) {
      loggerHelper.logBlue('[HOME] Auto-resuming tracking after app restart');
      await _trackingService.start(user);
    }
  }

  /// Gọi khi user thay đổi settings
  void onSettingsChanged(UserModel user) {
    maxSpeed.value = (user.maxSpeed ?? 60).toDouble();
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
}
