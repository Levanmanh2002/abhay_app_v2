import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/sign_in/view/form_card_view.dart';
import 'package:abhay_app_v2/pages/sign_in/view/header_signin_view.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sign_in_controller.dart';

class SignInPage extends GetWidget<SignInController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: appTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 42.h),
                HeaderSigninView(),
                SizedBox(height: 40.h),
                FormCardView(),
                SizedBox(height: 32.h),
                Obx(
                  () => CustomButton(
                    buttonText: 'sign_in_button'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isFormValid.value ? controller.onSignIn : null,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildRegisterRow(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'no_account'.tr,
          style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.SIGN_UP),
          child: Text(
            'register_now'.tr,
            style: StyleThemeData.size14Weight700(color: appTheme.appColor),
          ),
        ),
      ],
    );
  }
}
