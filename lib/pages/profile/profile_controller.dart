import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/resourese/service/notification/notification_service.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/easyloading_utils.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final NotificationService notificationService;
  final IProfileRepository profileRepository;

  ProfileController({required this.notificationService, required this.profileRepository});

  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final profile = await profileRepository.getProfile();
      userModel.value = profile;

      // Notify HomeController: apply settings + auto-resume tracking nếu cần
      if (profile != null && Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().onUserLoaded(profile);
      }
    } catch (error, stackTrace) {
      loggerHelper.error('Failed to fetch profile: $error', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  /// Cập nhật local model sau khi sửa thông tin (tránh gọi lại API)
  void updateProfile(UserModel updatedUser) {
    userModel.value = updatedUser;
    // Notify HomeController để apply settings mới ngay lập tức
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().onSettingsChanged(updatedUser);
    }
  }

  void onLogout() async {
    try {
      showEasyLoading();

      // Dừng tracking trước khi logout
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().isTracking.value ? Get.find<HomeController>().onToggleTracking(null) : null;
      }

      DialogUtils.showSuccessDialog('logout_success'.tr);
      final savedLanguage = LocalStorage.getString(SharedKey.language);
      await LocalStorage.clearAll();
      if (savedLanguage.isNotEmpty) {
        await LocalStorage.setString(SharedKey.language, savedLanguage);
      }
      await notificationService.deleteFcmToken();
      Get.offAllNamed(Routes.SIGN_IN);
    } catch (error, stackTrace) {
      loggerHelper.error('Failed to logout: $error', stackTrace: stackTrace);
    } finally {
      dismissEasyLoading();
    }
  }
}
