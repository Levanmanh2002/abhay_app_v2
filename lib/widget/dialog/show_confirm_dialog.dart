import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/custom_boder_button_widget.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showConfirmDialog({required String title, String titleBtn = '', VoidCallback? onConfirm, Color? colorBtn}) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: appTheme.whiteColor,
      child: Container(
        constraints: BoxConstraints(maxWidth: 452.w),
        padding: padding(all: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: StyleThemeData.size20Weight700(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: CustomBorderButtonWidget(
                    buttonText: 'cancel'.tr,
                    radius: 50,
                    onPressed: Get.back,
                    color: appTheme.grayE6Color,
                    paddingBtn: padding(all: 18),
                    isFullWidth: true,
                    styleButtonText: StyleThemeData.size16Weight700(),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    buttonText: titleBtn.isNotEmpty ? titleBtn : 'confirm'.tr,
                    radius: 50,
                    onPressed: () {
                      Get.back();
                      onConfirm!();
                    },
                    color: colorBtn ?? appTheme.red55Color,
                    textColor: appTheme.whiteColor,
                    paddingBtn: padding(all: 18),
                    isFullWidth: true,
                    styleButtonText: StyleThemeData.size16Weight700(color: appTheme.whiteColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
