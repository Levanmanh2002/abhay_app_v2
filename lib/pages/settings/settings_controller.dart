import 'package:abhay_app_v2/models/request/profile/user_request_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final IProfileRepository profileRepository;

  SettingsController({required this.profileRepository});

  // Speed
  final RxDouble speedLimit = 60.0.obs;
  final RxBool autoDetectSpeed = false.obs;

  // Sound
  final RxDouble soundLimit = 80.0.obs;
  final RxBool isMeasuringSound = false.obs;

  // Stop alert
  final RxBool isStopAlert = false.obs;

  // Delay time
  final RxString delayTime = '5s'.obs;
  final List<String> delayTimeOptions = ['2s', '5s', '7s', '10s', '15s'];

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromProfileController();
  }

  /// Ưu tiên đọc từ ProfileController (đã có sẵn, không cần gọi API lại)
  void _loadFromProfileController() {
    if (Get.isRegistered<ProfileController>()) {
      final user = Get.find<ProfileController>().userModel.value;
      if (user != null) {
        _fillFromUser(user);
        return;
      }
    }
    // Fallback: gọi API nếu ProfileController chưa có data
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    try {
      isLoading.value = true;
      final user = await profileRepository.getProfile();
      if (user != null) _fillFromUser(user);
    } catch (e) {
      loggerHelper.error('Load settings failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _fillFromUser(UserModel user) {
    speedLimit.value = user.maxSpeed?.toDouble() ?? 60.0;
    soundLimit.value = user.maxSound?.toDouble() ?? 80.0;
    isStopAlert.value = (user.isStopAlert ?? 0) == 1;
    autoDetectSpeed.value = (user.isAutoDetectSpeedLimit ?? 0) == 1;
    isMeasuringSound.value = (user.isMeasuringSound ?? 0) == 1;
    final delay = user.delayTimeAlert ?? 5;
    delayTime.value = '${delay}s';
  }

  Future<void> onSave() async {
    try {
      isSaving.value = true;

      final delaySeconds = int.tryParse(delayTime.value.replaceAll('s', '')) ?? 5;

      final params = UpdateUserParams(
        maxSpeed: speedLimit.value.round(),
        maxSound: soundLimit.value.round(),
        isStopAlert: isStopAlert.value ? 1 : 0,
        isAutoDetectSpeedLimit: autoDetectSpeed.value ? 1 : 0,
        isMeasuringSound: isMeasuringSound.value ? 1 : 0,
        delayTimeAlert: delaySeconds,
      );

      final updated = await profileRepository.updateProfile(params, []);

      if (updated != null) {
        // Sync ProfileController
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().updateProfile(updated);
        }
        // HomeController.onSettingsChanged đã được gọi trong ProfileController.updateProfile()
      }
    } catch (e) {
      loggerHelper.error('Save settings failed: $e');
      DialogUtils.showErrorDialog('settings_save_failed'.tr);
    } finally {
      isSaving.value = false;
    }
  }
}
