import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/upsert_supervised_users/upsert_supervised_users_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpsertSupervisedUsersPage extends GetWidget<UpsertSupervisedUsersController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: appTheme.background,
        appBar: DefaultAppBar(
          title: 'supervised_user_add'.tr,
          isBackIconCustom: true,
          backgroundColor: appTheme.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

                // ── Subtitle ──────────────────────
                Text(
                  'supervised_user_add_subtitle'.tr,
                  style: StyleThemeData.size14Weight400(
                    color: appTheme.gray86Color,
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Form Card ─────────────────────
                Container(
                  padding: padding(all: 20),
                  decoration: BoxDecoration(
                    color: appTheme.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.appColor.withAlpha(15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Fullname
                      CustomTextField(
                        controller: controller.fullNameController,
                        titleText: 'full_name'.tr,
                        hintText: 'full_name_hint'.tr,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        inputType: TextInputType.name,
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: appTheme.grayColor,
                          size: 20.w,
                        ),
                        onValidate: CustomValidator.validateFullName,
                      ),

                      SizedBox(height: 20.h),

                      // Phone
                      CustomTextField(
                        controller: controller.phoneController,
                        titleText: 'phone'.tr,
                        hintText: 'phone_hint'.tr,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        inputType: TextInputType.phone,
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: appTheme.grayColor,
                          size: 20.w,
                        ),
                        onValidate: CustomValidator.validatePhone,
                      ),

                      SizedBox(height: 20.h),

                      // Email
                      CustomTextField(
                        controller: controller.emailController,
                        titleText: 'email'.tr,
                        hintText: 'email_hint'.tr,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: appTheme.grayColor,
                          size: 20.w,
                        ),
                        onValidate: CustomValidator.validateEmail,
                      ),

                      SizedBox(height: 20.h),

                      Divider(color: appTheme.grayE6Color, height: 1),

                      SizedBox(height: 20.h),

                      // Password
                      CustomTextField(
                        controller: controller.passwordController,
                        titleText: 'password'.tr,
                        hintText: 'password_hint'.tr,
                        isPassword: true,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: appTheme.grayColor,
                          size: 20.w,
                        ),
                        onValidate: CustomValidator.validatePassword,
                      ),

                      SizedBox(height: 20.h),

                      // Confirm password
                      CustomTextField(
                        controller: controller.confirmPasswordController,
                        titleText: 'confirm_password'.tr,
                        hintText: 'password_hint'.tr,
                        isPassword: true,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: appTheme.grayColor,
                          size: 20.w,
                        ),
                        onValidate: (value) {
                          if (value != controller.passwordController.text) {
                            return 'passwords_do_not_match'.tr;
                          }
                          return '';
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Note OTP
                Padding(
                  padding: padding(horizontal: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6.w,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14.w,
                        color: appTheme.appColor,
                      ),
                      Expanded(
                        child: Text(
                          'supervised_user_otp_note'.tr,
                          style: StyleThemeData.size12Weight400(
                            color: appTheme.gray86Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Submit button
                Obx(
                  () => CustomButton(
                    buttonText: 'supervised_user_send_otp'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isFormValid.value ? controller.onSendOtpConfirm : null,
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
