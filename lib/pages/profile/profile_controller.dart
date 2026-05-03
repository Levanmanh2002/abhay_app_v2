import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/easyloading_utils.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final IProfileRepository profileRepository;

  ProfileController({required this.profileRepository});

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
    } catch (error, stackTrace) {
      loggerHelper.error('Failed to fetch profile: $error', stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  void updateProfile(UserModel updatedUser) {
    userModel.value = updatedUser;
  }

  void onLogout() async {
    try {
      showEasyLoading();

      DialogUtils.showSuccessDialog('logout_success'.tr);
      String? savedLanguage = LocalStorage.getString(SharedKey.language);

      await LocalStorage.clearAll();
      if (savedLanguage.isNotEmpty) {
        await LocalStorage.setString(SharedKey.language, savedLanguage);
      }

      Get.offAllNamed(Routes.SIGN_IN);
    } catch (error, stackTrace) {
      loggerHelper.error('Failed to logout: $error', stackTrace: stackTrace);
    } finally {
      dismissEasyLoading();
    }
  }
}
