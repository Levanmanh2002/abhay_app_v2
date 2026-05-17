import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class SoundGaugeView extends GetView<HomeController> {
  static const _soundColor = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profileController = Get.find<ProfileController>();
      final user = profileController.userModel.value;
      final sound = controller.sound.value;
      final limit = user?.maxSound?.toDouble() ?? 80.0;
      final isMeasuring = (user?.isMeasuringSound ?? 0) == 1;
      final isOver = controller.isOverSound.value;
      final color = !isMeasuring
          ? appTheme.grayColor
          : isOver
              ? appTheme.errorColor
              : _soundColor;
      final progressWidth =
          isMeasuring ? (sound / 150 * 20).clamp(4.0, 20.0) : 4.0;

      return Container(
        padding: padding(all: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: appTheme.whiteColor,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Label row
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
                      child: Icon(
                        isMeasuring ? Icons.mic_rounded : Icons.mic_off_rounded,
                        size: 16.w,
                        color: color,
                      ),
                    ),
                    Text(
                      'home_sound'.tr,
                      style: StyleThemeData.size14Weight700(),
                    ),
                  ],
                ),
                // Measuring badge / limit badge
                Container(
                  padding: padding(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    spacing: 4.w,
                    children: [
                      Icon(
                        isMeasuring ? Icons.warning_amber_rounded : Icons.mic_off_rounded,
                        size: 10.w,
                        color: color,
                      ),
                      Text(
                        isMeasuring ? '${'home_limit'.tr} ${limit.round()} dB' : 'home_sound_off'.tr,
                        style: StyleThemeData.size10Weight700(color: color),
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
              max: 150,
              initialValue: isMeasuring ? sound : 0,
              innerWidget: (_) => Transform.translate(
                offset: Offset(0, -12.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isMeasuring ? sound.toStringAsFixed(1) : '--',
                      style: StyleThemeData.size36Weight700(color: color),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4.w,
                      children: [
                        Text(
                          'dBA',
                          style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                        ),
                        Icon(isMeasuring ? Icons.mic_rounded : Icons.mic_off_rounded, size: 14.w, color: color),
                      ],
                    ),
                    if (!isMeasuring) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'home_sound_disabled'.tr,
                        style: StyleThemeData.size10Weight400(color: appTheme.grayColor),
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
                            'home_sound_over'.tr,
                            style: StyleThemeData.size12Weight700(
                              color: appTheme.errorColor,
                            ),
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
