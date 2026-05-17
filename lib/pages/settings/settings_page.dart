import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/settings/settings_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/line_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends GetWidget<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'settings_title'.tr,
        isBackIconCustom: true,
        backgroundColor: appTheme.background,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: appTheme.appColor));
        }
        return SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                _buildSection(
                  icon: Icons.speed_rounded,
                  title: 'settings_speed_title'.tr,
                  color: appTheme.appColor,
                  child: _buildSpeedSection(),
                ),
                SizedBox(height: 16.h),
                _buildSection(
                  icon: Icons.volume_up_rounded,
                  title: 'settings_sound_title'.tr,
                  color: const Color(0xFFFF6B35),
                  child: _buildSoundSection(),
                ),
                SizedBox(height: 16.h),
                _buildSection(
                  icon: Icons.pause_circle_outline_rounded,
                  title: 'settings_collision_title'.tr,
                  color: appTheme.secondaryColor,
                  child: _buildCollisionSection(),
                ),
                SizedBox(height: 16.h),
                _buildSection(
                  icon: Icons.settings_outlined,
                  title: 'settings_advanced_title'.tr,
                  color: appTheme.gray86Color,
                  child: _buildAdvancedSection(),
                ),
                SizedBox(height: 32.h),
                Obx(
                  () => CustomButton(
                    buttonText: 'save'.tr,
                    isLoading: controller.isSaving.value,
                    onPressed: controller.onSave,
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: padding(all: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appTheme.whiteColor,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.w,
            children: [
              Container(
                padding: padding(all: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withAlpha(15),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Text(
                title,
                style: StyleThemeData.size14Weight700(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LineWidget(color: appTheme.grayE6Color),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSpeedSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto detect toggle
          _buildToggleRow(
            label: 'settings_auto_detect'.tr,
            value: controller.autoDetectSpeed.value,
            onChanged: (v) => controller.autoDetectSpeed.value = v,
          ),

          if (!controller.autoDetectSpeed.value) ...[
            SizedBox(height: 16.h),
            _buildSlider(
              label: 'settings_speed_limit'.tr,
              value: controller.speedLimit.value,
              min: 20,
              max: 250,
              unit: 'km/h',
              color: appTheme.appColor,
              onChanged: (v) => controller.speedLimit.value = v,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSoundSection() {
    return Obx(
      () => Column(
        spacing: 12.h,
        children: [
          _buildToggleRow(
            label: 'settings_measuring_sound'.tr,
            value: controller.isMeasuringSound.value,
            onChanged: (v) => controller.isMeasuringSound.value = v,
          ),
          if (controller.isMeasuringSound.value)
            _buildSlider(
              label: 'settings_sound_limit'.tr,
              value: controller.soundLimit.value,
              min: 50,
              max: 120,
              unit: 'dB',
              color: const Color(0xFFFF6B35),
              onChanged: (v) => controller.soundLimit.value = v,
            ),
        ],
      ),
    );
  }

  Widget _buildCollisionSection() {
    return Obx(
      () => _buildToggleRow(
        label: 'settings_stop_alert'.tr,
        value: controller.isStopAlert.value,
        onChanged: (v) => controller.isStopAlert.value = v,
      ),
    );
  }

  Widget _buildAdvancedSection() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  'settings_delay_time'.tr,
                  style: StyleThemeData.size14Weight400(),
                ),
                Text(
                  'settings_delay_time_note'.tr,
                  style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: appTheme.appColor, width: 1.w),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.delayTime.value,
                isDense: true,
                padding: padding(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(10),
                dropdownColor: appTheme.whiteColor,
                items: controller.delayTimeOptions.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: StyleThemeData.size14Weight700(
                        color: appTheme.appColor,
                      ),
                    ),
                  );
                }).toList(),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.w,
                  color: appTheme.appColor,
                ),
                onChanged: (v) {
                  if (v != null) controller.delayTime.value = v;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: StyleThemeData.size14Weight400(color: appTheme.blackColor),
          ),
        ),
        CupertinoSwitch(
          value: value,
          activeTrackColor: appTheme.appColor,
          inactiveThumbColor: appTheme.whiteColor,
          inactiveTrackColor: appTheme.grayC0Color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.h,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: StyleThemeData.size14Weight400(color: appTheme.blackColor),
            ),
            Container(
              padding: padding(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${value.round()} $unit',
                style: StyleThemeData.size12Weight700(color: color),
              ),
            ),
          ],
        ),
        Row(
          spacing: 8.w,
          children: [
            Text(
              '${min.round()}',
              style: StyleThemeData.size12Weight400(color: appTheme.grayColor),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6.w,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 3),
                  overlayShape: SliderComponentShape.noThumb,
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: (max - min).round(),
                  activeColor: color,
                  inactiveColor: appTheme.grayE6Color,
                  thumbColor: appTheme.whiteColor,
                  onChanged: onChanged,
                ),
              ),
            ),
            Text(
              '${max.round()}',
              style: StyleThemeData.size12Weight400(color: color),
            ),
          ],
        ),
      ],
    );
  }
}
