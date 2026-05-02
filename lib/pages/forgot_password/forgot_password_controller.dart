import 'package:abhay_app_v2/pages/otp/otp_parameter.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final IAuthRepository authRepository;

  ForgotPasswordController({required this.authRepository});

  final TextEditingController emailController = TextEditingController();

  var isFormValid = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = emailController.text.trim();
    isFormValid.value = CustomValidator.validateEmail(email).isEmpty;
  }

  Future<void> onSubmit() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final result = await authRepository.forgotPassword(email);

      if (result) {
        Get.toNamed(
          Routes.OTP,
          arguments: OtpParameter(email: email, type: OtpType.forgotPassword),
        );
      }
    } catch (e) {
      loggerHelper.error('Forgot password failed: $e');
      DialogUtils.showErrorDialog('forgot_password_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
