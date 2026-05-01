import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: height),
          Assets.images.placeholder.image(width: 107.w, height: 88.h),
          SizedBox(height: 16.h),
          Text(
            'no_data'.tr,
            style: StyleThemeData.size16Weight700(color: appTheme.gray78Color),
          ),
        ],
      ),
    );
  }
}
