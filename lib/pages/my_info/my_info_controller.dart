import 'package:abhay_app_v2/models/media/post_media.dart';
import 'package:abhay_app_v2/models/request/profile/user_request_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/resourese/ibase_repository.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/image_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'my_info_parameter.dart';

class MyInfoController extends GetxController {
  final MyInfoParameter parameter;
  final IProfileRepository profileRepository;
  final ProfileController profileController;

  MyInfoController({required this.parameter, required this.profileRepository, required this.profileController});

  late TextEditingController fullnameController;
  late TextEditingController phoneController;

  Rx<UserModel?> user = Rx<UserModel?>(null);
  Rx<PostMedia?> avatarFile = Rx<PostMedia?>(null);
  var isLoading = false.obs;
  var isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = parameter.user;
    fullnameController = TextEditingController(text: user.value?.fullname ?? '')..addListener(_validateForm);
    phoneController = TextEditingController(text: user.value?.phoneVerified ?? '')..addListener(_validateForm);
  }

  void _validateForm() {
    final fullName = fullnameController.text.trim();
    final phone = phoneController.text.trim();
    final isFullNameChanged = fullName != user.value?.fullname;
    final isPhoneChanged = phone != user.value?.phoneVerified;

    isFormValid.value = (CustomValidator.validateFullName(fullName).isEmpty &&
            CustomValidator.validatePhone(phone).isEmpty &&
            (isFullNameChanged || isPhoneChanged)) ||
        avatarFile.value != null;
  }

  void onPickImageAvatar() async {
    final file = await ImageUtils.pickImage();

    if (file != null) {
      avatarFile.value = PostMedia(file: file);
      _validateForm();
    }
  }

  void updateProfile() async {
    try {
      isLoading.value = true;

      UpdateUserParams params = UpdateUserParams(
        fullName: fullnameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      List<MultipartBody> multipartBody =
          avatarFile.value != null ? [MultipartBody('avatar', avatarFile.value?.file)] : [];

      final updatedUser = await profileRepository.updateProfile(params, multipartBody);

      if (updatedUser != null) {
        user.value = updatedUser;
        profileController.updateProfile(updatedUser);
        Get.back();
      }
    } catch (error) {
      loggerHelper.error('Failed to update profile $error');
      DialogUtils.showErrorDialog('update_profile_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullnameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
