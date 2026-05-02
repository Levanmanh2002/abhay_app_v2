import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/splash/splash_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends GetWidget<SplashController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.appColor,
      body: Stack(
        children: [
          Positioned(
            top: -60.w,
            right: -60.w,
            child: Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appTheme.whiteColor.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            bottom: -80.w,
            left: -80.w,
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appTheme.whiteColor.withAlpha(10),
              ),
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(scale: 0.6 + (0.4 * value), child: child),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.images.logoApp.logo.image(width: 88.w, height: 88.w),
                  SizedBox(height: 16.h),
                  Text(
                    AppConstants.appName,
                    style: StyleThemeData.size24Weight700(color: appTheme.whiteColor),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      return Container(
                        margin: padding(horizontal: 3.w),
                        width: i == 1 ? 20.w : 6.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: i == 1 ? appTheme.secondaryColor : appTheme.whiteColor.withAlpha(100),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 48.h,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(appTheme.whiteColor.withAlpha(180)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
