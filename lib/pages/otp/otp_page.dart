import 'package:abhay_app_v2/core/app_border_shadow.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/otp/otp_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpPage extends GetWidget<OtpController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: appTheme.background,
        appBar: DefaultAppBar(
          backButton: true,
          isBackIconCustom: true,
          backgroundColor: appTheme.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding(top: 8, horizontal: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'otp_title'.tr,
                  style: StyleThemeData.size28Weight700(),
                ),
                SizedBox(height: 8.h),
                RichText(
                  text: TextSpan(
                    style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                    children: [
                      TextSpan(text: 'otp_subtitle'.tr),
                      TextSpan(
                        text: controller.parameter.email,
                        style: StyleThemeData.size14Weight700(color: appTheme.appColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  padding: padding(all: 24),
                  decoration: BoxDecoration(
                    color: appTheme.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppBorderShadow.boxShadowAuth,
                  ),
                  child: Column(
                    spacing: 24.h,
                    children: [
                      _buildOtpInput(),
                      _buildResendWidget(),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Obx(
                  () => CustomButton(
                    buttonText: 'confirm'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.verificationCode.value.length == AppConstants.otpLength
                        ? controller.onConfirm
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return Obx(() {
      final hasError = controller.otpError.value.isNotEmpty;

      return Column(
        children: [
          PinCodeTextField(
            appContext: Get.context!,
            controller: controller.otpTextController,
            length: AppConstants.otpLength,
            onChanged: controller.updateVerificationCode,
            onCompleted: (_) => controller.onConfirm(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enableActiveFill: true,
            animationType: AnimationType.fade,
            animationDuration: const Duration(milliseconds: 200),
            cursorColor: appTheme.appColor,
            obscureText: false,
            autovalidateMode: AutovalidateMode.disabled,
            textStyle: StyleThemeData.size18Weight700(),
            hintStyle: StyleThemeData.size18Weight700(color: appTheme.grayC0Color),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(12),
              fieldHeight: 52.w,
              fieldWidth: 52.w,
              activeFillColor: hasError ? appTheme.errorColor.withAlpha(15) : appTheme.appColor.withAlpha(15),
              inactiveFillColor: appTheme.grayF3Color,
              selectedFillColor: appTheme.appColor.withAlpha(15),
              activeColor: hasError ? appTheme.errorColor : appTheme.appColor,
              inactiveColor: appTheme.grayE6Color,
              selectedColor: appTheme.appColor,
              borderWidth: 1.w,
              activeBorderWidth: 1.5.w,
              selectedBorderWidth: 1.5.w,
              inactiveBorderWidth: 1.w,
            ),
            onSubmitted: (value) {
              if (value.length == AppConstants.otpLength) {
                controller.onConfirm();
              }
            },
          ),
          if (hasError) ...[
            SizedBox(height: 12.h),
            Text(
              controller.otpError.value,
              style: StyleThemeData.size12Weight400(color: appTheme.errorColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    });
  }

  Widget _buildResendWidget() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'otp_no_code'.tr,
            style: StyleThemeData.size14Weight400(),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: controller.canResend.value ? controller.resendOtp : null,
            child: Text(
              controller.canResend.value ? 'otp_resend'.tr : '${'otp_resend'.tr} (${controller.countdown.value}s)',
              style: StyleThemeData.size14Weight700(
                color: controller.canResend.value ? appTheme.appColor : appTheme.grayColor,
              ),
            ),
          ),
        ],
      );
    });
  }
}
