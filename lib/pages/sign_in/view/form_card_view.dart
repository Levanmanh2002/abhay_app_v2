import 'package:abhay_app_v2/core/app_border_shadow.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/sign_in/sign_in_controller.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormCardView extends GetView<SignInController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding(all: 20),
      decoration: BoxDecoration(
        color: appTheme.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppBorderShadow.boxShadowAuth,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller.emailController,
            titleText: 'email'.tr,
            hintText: 'email_hint'.tr,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email_outlined, color: appTheme.grayColor, size: 20.w),
            onValidate: CustomValidator.validateEmail,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: controller.passwordController,
            titleText: 'password'.tr,
            hintText: 'password_hint'.tr,
            isPassword: true,
            showBorder: false,
            inputType: TextInputType.visiblePassword,
            fillColor: appTheme.grayF3Color,
            prefixIcon: Icon(Icons.lock_outline_rounded, color: appTheme.grayColor, size: 20.w),
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Get.toNamed(Routes.FORGOT_PASSWORD),
              child: Text(
                'forgot_password'.tr,
                style: StyleThemeData.size12Weight700(color: appTheme.appColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
