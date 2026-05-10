import 'package:abhay_app_v2/models/request/supervised_users/supervised_users_model.dart';
import 'package:abhay_app_v2/pages/otp/otp_parameter.dart';
import 'package:abhay_app_v2/resourese/supervised_users/isupervised_users_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpsertSupervisedUsersController extends GetxController {
  final ISupervisedUsersRepository supervisedUsersRepository;

  UpsertSupervisedUsersController({required this.supervisedUsersRepository});

  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  var isFormValid = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fullNameController = TextEditingController()..addListener(_validateForm);
    phoneController = TextEditingController()..addListener(_validateForm);
    emailController = TextEditingController()..addListener(_validateForm);
    passwordController = TextEditingController()..addListener(_validateForm);
    confirmPasswordController = TextEditingController()..addListener(_validateForm);
  }

  void _validateForm() {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    isFormValid.value = CustomValidator.validateFullName(fullName).isEmpty &&
        CustomValidator.validatePhone(phone).isEmpty &&
        CustomValidator.validateEmail(email).isEmpty &&
        CustomValidator.validatePassword(password).isEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;
  }

  void onSendOtpConfirm() async {
    isLoading.value = true;

    try {
      final fullName = fullNameController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();

      final result = await supervisedUsersRepository.sendOTPChild(fullName: fullName, email: email);

      if (result) {
        SupervisedUsersModel supervisedUser = SupervisedUsersModel(
          fullname: fullName,
          email: email,
          phone: phone,
          password: password,
          passwordConfirm: password,
        );

        Get.toNamed(
          Routes.OTP,
          arguments: OtpParameter(email: email, type: OtpType.supervisedUser, supervisedUser: supervisedUser),
        );
      }
    } catch (e) {
      loggerHelper.error('Failed to send OTP: $e');
      DialogUtils.showErrorDialog('otp_sent_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
