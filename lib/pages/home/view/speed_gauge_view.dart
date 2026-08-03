import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SpeedGaugeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final speed = controller.speed.value;
      final limit = controller.effectiveLimit;
      final fromRoadSign = controller.isLimitFromRoadSign;
      final isOver = controller.isOverSpeed.value;
      final color = isOver ? appTheme.errorColor : appTheme.appColor;
      final progressWidth = (speed / 250 * 20).clamp(4.0, 20.0);

      return Container(
        padding: padding(all: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: appTheme.whiteColor,
          boxShadow: [
            BoxShadow(color: color.withAlpha(20), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 6.w,
                  children: [
                    Container(
                      padding: padding(all: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: color.withAlpha(15),
                      ),
                      child: Icon(Icons.speed_rounded, size: 16.w, color: color),
                    ),
                    Text(
                      'home_speed'.tr,
                      style: StyleThemeData.size14Weight700(),
                    ),
                  ],
                ),
                Container(
                  padding: padding(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOver ? appTheme.errorColor.withAlpha(15) : appTheme.appColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    spacing: 4.w,
                    children: [
                      Icon(
                        fromRoadSign ? Icons.signpost_rounded : Icons.warning_amber_rounded,
                        size: 10.w,
                        color: isOver ? appTheme.errorColor : appTheme.appColor,
                      ),
                      Text(
                        '${'home_limit'.tr} ${limit.round()} km/h${fromRoadSign ? ' 🚧' : ''}',
                        style: StyleThemeData.size10Weight700(
                          color: isOver ? appTheme.errorColor : appTheme.appColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SleekCircularSlider(
              appearance: CircularSliderAppearance(
                startAngle: 170,
                angleRange: 200,
                customWidths: CustomSliderWidths(
                  trackWidth: 16.w,
                  progressBarWidth: progressWidth.w,
                  handlerSize: 0,
                ),
                customColors: CustomSliderColors(
                  trackColor: appTheme.grayF3Color,
                  progressBarColor: color,
                  hideShadow: true,
                ),
                size: 190.w,
              ),
              min: 0,
              max: 250,
              initialValue: speed,
              innerWidget: (_) => Transform.translate(
                offset: Offset(0, -12.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      speed.toStringAsFixed(1),
                      style: StyleThemeData.size36Weight700(color: color),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4.w,
                      children: [
                        Text(
                          'km/h',
                          style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                        ),
                        Icon(Icons.speed_rounded, size: 14.w, color: color),
                      ],
                    ),
                    if (controller.isTracking.value && limit > 0) ...[
                      SizedBox(height: 4.h),
                      Text(
                        '${'home_limit'.tr} ${limit.round()} km/h',
                        style: StyleThemeData.size10Weight400(color: appTheme.gray86Color),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isOver
                  ? Container(
                      key: const ValueKey('over'),
                      padding: padding(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: appTheme.errorColor.withAlpha(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 6.w,
                        children: [
                          Icon(Icons.warning_rounded, size: 14.w, color: appTheme.errorColor),
                          Text(
                            'home_speed_over'.tr,
                            style: StyleThemeData.size12Weight700(color: appTheme.errorColor),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(key: ValueKey('ok')),
            ),
          ],
        ),
      );
    });
  }
}
