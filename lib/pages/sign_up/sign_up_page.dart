import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/sign_up/sign_up_controller.dart';
import 'package:abhay_app_v2/pages/sign_up/view/form_signup_view.dart';
import 'package:abhay_app_v2/pages/sign_up/view/header_signup_view.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends GetWidget<SignUpController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: appTheme.background,
        appBar: DefaultAppBar(
          backgroundColor: appTheme.background,
          isBackIconCustom: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding(top: 24, horizontal: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderSignupView(),
                SizedBox(height: 24.h),
                FormSignupView(),
                SizedBox(height: 24.h),
                Obx(
                  () => CustomButton(
                    buttonText: 'sign_up_button'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isFormValid.value ? controller.onSignUp : null,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildSignInRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_account'.tr,
          style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.SIGN_IN),
          child: Text(
            'sign_in_now'.tr,
            style: StyleThemeData.size14Weight700(color: appTheme.appColor),
          ),
        ),
      ],
    );
  }
}
