import 'package:abhay_app_v2/pages/change_password/change_password_parameter.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final ChangePasswordParameter parameter;
  final IAuthRepository authRepository;

  ChangePasswordController({required this.parameter, required this.authRepository});

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var isFormValid = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    newPasswordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    isFormValid.value = CustomValidator.validatePassword(newPassword).isEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }

  void onChangePassword() async {
    try {
      isLoading.value = true;

      final newPassword = newPasswordController.text.trim();

      final result = await authRepository.resetPassword(parameter.email, newPassword);

      if (result) {
        Get.until((route) => Get.currentRoute == Routes.SIGN_IN);
      }
    } catch (e) {
      Get.snackbar('Error', 'reset_password_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
