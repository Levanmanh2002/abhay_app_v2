import 'package:abhay_app_v2/core/app_border_shadow.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/update_password/update_password_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/formatter_util.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/line_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePasswordPage extends GetWidget<UpdatePasswordController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: appTheme.background,
        appBar: DefaultAppBar(
          title: 'profile_change_password'.tr,
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
                Container(
                  padding: padding(all: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppBorderShadow.boxShadowAuth,
                    color: appTheme.whiteColor,
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: controller.currentPasswordController,
                        titleText: 'current_password'.tr,
                        hintText: 'password_hint'.tr,
                        isPassword: true,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        inputType: TextInputType.visiblePassword,
                        inputFormatters: FormatterUtil.passwordFormatter,
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: appTheme.grayColor, size: 20.w),
                      ),
                      SizedBox(height: 20.h),
                      LineWidget(color: appTheme.grayE6Color),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: controller.newPasswordController,
                        titleText: 'new_password'.tr,
                        hintText: 'password_hint'.tr,
                        isPassword: true,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        inputType: TextInputType.visiblePassword,
                        inputFormatters: FormatterUtil.passwordFormatter,
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: appTheme.grayColor, size: 20.w),
                        onValidate: CustomValidator.validatePassword,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextField(
                        controller: controller.confirmPasswordController,
                        titleText: 'confirm_password'.tr,
                        hintText: 'password_hint'.tr,
                        isPassword: true,
                        showBorder: false,
                        fillColor: appTheme.grayF3Color,
                        inputType: TextInputType.visiblePassword,
                        inputFormatters: FormatterUtil.passwordFormatter,
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: appTheme.grayColor, size: 20.w),
                        onValidate: (value) {
                          if (value != controller.newPasswordController.text) {
                            return 'passwords_do_not_match'.tr;
                          }
                          return '';
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: padding(horizontal: 4),
                  child: Text(
                    'update_password_note'.tr,
                    style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                  ),
                ),
                SizedBox(height: 32.h),
                Obx(
                  () => CustomButton(
                    buttonText: 'save'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isFormValid.value ? controller.onUpdatePassword : null,
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
