import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/pages/home/view/home_header_view.dart';
import 'package:abhay_app_v2/pages/home/view/sound_gauge_view.dart';
import 'package:abhay_app_v2/pages/home/view/speed_gauge_view.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetWidget<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: padding(horizontal: 16, top: 16, bottom: 32),
          child: Column(
            spacing: 16.h,
            children: [
              HomeHeaderView(),
              SpeedGaugeView(),
              SoundGaugeView(),
              _buildTrackingButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingButton() {
    return Obx(() {
      final isTracking = controller.isTracking.value;
      return InkWell(
        onTap: () => controller.isTracking.toggle(),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isTracking ? [appTheme.errorColor, appTheme.red55Color] : [appTheme.appColor, appTheme.blueBFFColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isTracking ? appTheme.errorColor : appTheme.appColor).withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10.w,
            children: [
              Icon(
                isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                color: appTheme.whiteColor,
                size: 24.w,
              ),
              Text(
                isTracking ? 'home_stop_tracking'.tr : 'home_start_tracking'.tr,
                style: StyleThemeData.size16Weight700(color: appTheme.whiteColor),
              ),
            ],
          ),
        ),
      );
    });
  }
}
