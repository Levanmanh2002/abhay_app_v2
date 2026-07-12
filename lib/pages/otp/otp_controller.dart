import 'dart:async';

import 'package:abhay_app_v2/models/request/supervised_users/verify_otp_child_request.dart';
import 'package:abhay_app_v2/pages/change_password/change_password_parameter.dart';
import 'package:abhay_app_v2/pages/otp/otp_parameter.dart';
import 'package:abhay_app_v2/pages/supervised_users/supervised_users_controller.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/resourese/supervised_users/isupervised_users_repository.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/easyloading_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final OtpParameter parameter;
  final IAuthRepository authRepository;
  final ISupervisedUsersRepository supervisedUsersRepository;

  OtpController({required this.parameter, required this.authRepository, required this.supervisedUsersRepository});

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

      if (parameter.type == OtpType.supervisedUser) {
        final result = await supervisedUsersRepository.sendOTPChild(
          fullName: parameter.supervisedUser?.fullname ?? '',
          email: parameter.supervisedUser?.email ?? '',
        );
        if (result) {
          verificationCode.value = '';
          otpError.value = '';
          otpTextController.clear();
          startCountdown();
        }
        return;
      }

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

      if (parameter.type == OtpType.supervisedUser) {
        final request = VerifyOtpChildRequest(
          fullname: parameter.supervisedUser?.fullname,
          phoneVerified: parameter.supervisedUser?.phone,
          email: parameter.supervisedUser?.email,
          password: parameter.supervisedUser?.password,
          passwordConfirmation: parameter.supervisedUser?.password,
          gender: '1',
          active: '1',
          maxSound: '100',
          maxSpeed: '100',
          isStopAlert: '0',
          delayTimeAlert: '10',
          otp: verificationCode.value,
        );
        final result = await authRepository.verifyOTPAddChild(request);

        if (result) {
          if (Get.isRegistered<SupervisedUsersController>()) {
            final supervisedUsersController = Get.find<SupervisedUsersController>();
            supervisedUsersController.fetchSupervisedUsers();
          }
          Get.until((route) => Get.currentRoute == Routes.SUPERVISED_USERS);
        } else {
          otpError.value = 'otp_invalid'.tr;
        }
        return;
      }

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
  void dispose() {
    _timer?.cancel();
    otpTextController.dispose();
    super.dispose();
  }
}
