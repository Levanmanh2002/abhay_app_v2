import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePasswordController extends GetxController {
  final IProfileRepository profileRepository;

  UpdatePasswordController({required this.profileRepository});

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var isFormValid = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentPasswordController.addListener(_validateForm);
    newPasswordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    isFormValid.value = CustomValidator.validatePassword(newPassword).isEmpty &&
        currentPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }

  void onUpdatePassword() async {
    try {
      isLoading.value = true;

      final currentPassword = currentPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();

      final result = await profileRepository.changePassword(
        oldPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirm: newPassword,
      );

      if (result) {
        Get.back();
      }
    } catch (e) {
      loggerHelper.error('Update password failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
