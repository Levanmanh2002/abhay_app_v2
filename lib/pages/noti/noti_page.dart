import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/pages/noti/noti_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotiPage extends GetWidget<NotiController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'tab_notification'.tr,
        backButton: false,
        backgroundColor: appTheme.background,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: appTheme.appColor));
          }

          if (controller.notiAlerts.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: appTheme.appColor,
            onRefresh: () async => controller.fetchNotiAlerts(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding(horizontal: 24, vertical: 16),
              itemCount: controller.notiAlerts.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, index) => _buildAlertCard(controller.notiAlerts[index]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAlertCard(NotiAlertModel alert) {
    final config = _typeConfig(alert.type);

    return Container(
      padding: padding(all: 16),
      decoration: BoxDecoration(
        color: appTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: config.color.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: config.color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(config.icon, color: config.color, size: 22.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title ?? config.labelKey.tr,
                        style: StyleThemeData.size14Weight700(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatTime(alert.createdAt),
                      style: StyleThemeData.size10Weight400(color: appTheme.grayColor),
                    ),
                  ],
                ),
                if (alert.message?.isNotEmpty == true)
                  Text(
                    alert.message!,
                    style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (alert.location?.isNotEmpty == true)
                  Row(
                    spacing: 4.w,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12.w,
                        color: appTheme.grayColor,
                      ),
                      Expanded(
                        child: Text(
                          alert.location!,
                          style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: [
                    if (alert.sender?.isNotEmpty == true)
                      _chip(
                        Icons.person_outline_rounded,
                        alert.sender!,
                        appTheme.appColor,
                      ),
                    if (alert.speed != null && alert.type == 2)
                      _chip(
                        Icons.speed_rounded,
                        '${alert.speed?.toStringAsFixed(0)} km/h',
                        config.color,
                      ),
                    if (alert.speedLimit != null && alert.type == 2)
                      _chip(
                        Icons.warning_amber_rounded,
                        '${'noti_limit'.tr} ${alert.speedLimit} km/h',
                        appTheme.errorColor,
                      ),
                    if (alert.sound != null && alert.type == 1)
                      _chip(
                        Icons.volume_up_outlined,
                        '${alert.sound?.toStringAsFixed(0)} dB',
                        config.color,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: padding(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withAlpha(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3.w,
        children: [
          Icon(icon, size: 10.w, color: color),
          Text(
            label,
            style: StyleThemeData.size10Weight700(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12.h,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: appTheme.appColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 36.w,
              color: appTheme.appColor,
            ),
          ),
          Text(
            'noti_empty'.tr,
            style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  _NotiTypeConfig _typeConfig(int? type) {
    switch (type) {
      case 1:
        return _NotiTypeConfig(
          icon: Icons.volume_up_rounded,
          color: appTheme.appColor,
          labelKey: 'noti_type_sound',
        );
      case 2:
        return _NotiTypeConfig(
          icon: Icons.speed_rounded,
          color: appTheme.errorColor,
          labelKey: 'noti_type_speed',
        );
      case 3:
        return _NotiTypeConfig(
          icon: Icons.pause_circle_outline_rounded,
          color: appTheme.secondaryColor,
          labelKey: 'noti_type_stop',
        );
      default:
        return _NotiTypeConfig(
          icon: Icons.notifications_outlined,
          color: appTheme.appColor,
          labelKey: 'noti_type_default',
        );
    }
  }

  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'just_now'.tr;
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class _NotiTypeConfig {
  final IconData icon;
  final Color color;
  final String labelKey;

  const _NotiTypeConfig({
    required this.icon,
    required this.color,
    required this.labelKey,
  });
}
