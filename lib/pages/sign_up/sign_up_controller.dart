import 'package:abhay_app_v2/extension/date_time_extension.dart';
import 'package:abhay_app_v2/models/request/auth/sign_up_request_model.dart';
import 'package:abhay_app_v2/pages/otp/otp_parameter.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/app/gender_utils.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final IAuthRepository authRepository;

  SignUpController({required this.authRepository});

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Rx<DateTime?> selectedBirthday = Rx<DateTime?>(null);
  Rx<Gender> selectedGender = Rx<Gender>(Gender.male);

  var isFormValid = false.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fullnameController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    birthdayController.addListener(_validateForm);
    addressController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final fullname = fullnameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final birthday = birthdayController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    isFormValid.value = CustomValidator.validateFullName(fullname).isEmpty &&
        CustomValidator.validatePhone(phone).isEmpty &&
        CustomValidator.validateEmail(email).isEmpty &&
        CustomValidator.validatePassword(password).isEmpty &&
        CustomValidator.validateAddress(addressController.text).isEmpty &&
        birthday.isNotEmpty &&
        selectedBirthday.value != null &&
        address.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;
  }

  void onSelectBirthday(DateTime? date) {
    selectedBirthday.value = date;
    birthdayController.text = date != null ? date.toddMMyyyy : '';
    _validateForm();
  }

  void onSelectGender(Gender? gender) {
    selectedGender.value = gender ?? Gender.male;
    _validateForm();
  }

  void onSignUp() async {
    try {
      isLoading.value = true;

      final fullname = fullnameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final gender = selectedGender.value;
      final birthday = selectedBirthday.value;
      final address = addressController.text.trim();
      final password = passwordController.text.trim();

      SignUpRequestModel request = SignUpRequestModel(
        fullname: fullname,
        phone: phone,
        email: email,
        gender: gender == Gender.male
            ? 1
            : gender == Gender.female
                ? 2
                : 0,
        birthday: birthday?.toyyyyMMdd ?? '',
        address: address,
        password: password,
        passwordConfirmation: password,
      );

      final result = await authRepository.signUp(request);

      if (result) {
        Get.toNamed(Routes.OTP, arguments: OtpParameter(email: email, type: OtpType.signUp));
      }
    } catch (e) {
      loggerHelper.error('Sign up failed: $e');
      DialogUtils.showErrorDialog('sign_up_failed'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
