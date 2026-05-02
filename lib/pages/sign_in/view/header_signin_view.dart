import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/sign_in/sign_in_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderSigninView extends GetView<SignInController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10.w,
          children: [
            Center(child: Assets.images.logoApp.logo.image(width: 42.w, height: 42.w)),
            Text(
              AppConstants.appName,
              style: StyleThemeData.size20Weight700(color: appTheme.appColor),
            ),
          ],
        ),
        SizedBox(height: 32.h),
        Text(
          'sign_in_welcome'.tr,
          style: StyleThemeData.size28Weight700(),
        ),
        SizedBox(height: 8.h),
        Text(
          'sign_in_subtitle'.tr,
          style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
        ),
      ],
    );
  }
}
