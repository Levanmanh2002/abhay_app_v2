import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  final IAuthRepository authRepository;

  SignInController({required this.authRepository});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var isFormValid = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = emailController.text.trim();
    isFormValid.value = CustomValidator.validateEmail(email).isEmpty && passwordController.text.isNotEmpty;
  }

  Future<void> onSignIn() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final result = await authRepository.signIn(email, password);

      if (result) {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e) {
      loggerHelper.error('Sign in failed: $e');
      DialogUtils.showErrorDialog('sign_in_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
