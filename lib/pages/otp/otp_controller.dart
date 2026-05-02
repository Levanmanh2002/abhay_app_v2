import 'dart:async';

import 'package:abhay_app_v2/pages/change_password/change_password_parameter.dart';
import 'package:abhay_app_v2/pages/otp/otp_parameter.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/easyloading_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final OtpParameter parameter;
  final IAuthRepository authRepository;

  OtpController({required this.parameter, required this.authRepository});

  final TextEditingController otpTextController = TextEditingController();
  final RxString verificationCode = ''.obs;
  final RxString otpError = ''.obs;
  final RxInt countdown = 60.obs;
  final RxBool canResend = false.obs;
  final RxBool isLoading = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startCountdown();
  }

  void startCountdown() {
    canResend.value = false;
    countdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void updateVerificationCode(String value) {
    verificationCode.value = value;
    if (otpError.value.isNotEmpty) {
      otpError.value = '';
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;
    try {
      showEasyLoading();

      final response = await authRepository.resendOtp(parameter.email);
      if (response) {
        verificationCode.value = '';
        otpError.value = '';
        otpTextController.clear();
        startCountdown();
      }
    } catch (e) {
      loggerHelper.error('Resend OTP failed: $e');
      DialogUtils.showErrorDialog('otp_resend_failed'.tr);
    } finally {
      dismissEasyLoading();
    }
  }

  Future<void> onConfirm() async {
    try {
      isLoading.value = true;
      final result = await authRepository.verifyOtp(parameter.email, verificationCode.value);
      if (result) {
        if (parameter.type == OtpType.forgotPassword) {
          Get.offNamed(Routes.CHANGE_PASSWORD, arguments: ChangePasswordParameter(email: parameter.email));
        } else {
          Get.until((route) => Get.currentRoute == Routes.SIGN_IN);
        }
      } else {
        otpError.value = 'otp_invalid'.tr;
      }
    } catch (e) {
      loggerHelper.error('Verify OTP failed: $e');
      otpError.value = 'otp_invalid'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpTextController.dispose();
    super.onClose();
  }
}
