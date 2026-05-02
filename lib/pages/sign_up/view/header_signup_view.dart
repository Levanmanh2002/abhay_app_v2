import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/sign_up/sign_up_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeaderSignupView extends GetView<SignUpController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sign_up_welcome'.tr,
          style: StyleThemeData.size28Weight700(),
        ),
        Text(
          'sign_up_subtitle'.tr,
          style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
        ),
      ],
    );
  }
}
