import 'package:abhay_app_v2/core/app_border_shadow.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/forgot_password/forgot_password_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends GetWidget<ForgotPasswordController> {
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
            padding: padding(top: 24, horizontal: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('forgot_password_title'.tr, style: StyleThemeData.size28Weight700()),
                SizedBox(height: 8.h),
                Text(
                  'forgot_password_subtitle'.tr,
                  style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                ),
                SizedBox(height: 32.h),
                Container(
                  padding: padding(all: 20),
                  decoration: BoxDecoration(
                    color: appTheme.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppBorderShadow.boxShadowAuth,
                  ),
                  child: CustomTextField(
                    controller: controller.emailController,
                    titleText: 'email'.tr,
                    hintText: 'email_hint'.tr,
                    showBorder: false,
                    fillColor: appTheme.grayF3Color,
                    inputType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.email_outlined, color: appTheme.grayColor, size: 20.w),
                    onValidate: CustomValidator.validateEmail,
                  ),
                ),
                SizedBox(height: 32.h),
                Obx(
                  () => CustomButton(
                    buttonText: 'forgot_password_button'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isFormValid.value ? controller.onSubmit : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
