import 'package:abhay_app_v2/extension/string_extension.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/pages/receive/receive_controller.dart';
import 'package:abhay_app_v2/pages/receive/widget/receive_empty.dart';
import 'package:abhay_app_v2/pages/received_alert_detail/received_alert_detail_parameter.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertsTabView extends GetView<ReceiveController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingAlerts.value) {
        return Center(child: CircularProgressIndicator(color: appTheme.appColor));
      }
      if (controller.receivedAlerts.isEmpty) {
        return ReceiveEmpty(message: 'receive_empty_alerts'.tr, icon: Icons.notifications_none_outlined);
      }

      return RefreshIndicator(
        color: appTheme.appColor,
        onRefresh: controller.fetchAlerts,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding(horizontal: 16, vertical: 8),
          itemCount: controller.receivedAlerts.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => _buildAlertCard(controller.receivedAlerts[i]),
        ),
      );
    });
  }

  Widget _buildAlertCard(NotiAlertModel alert) {
    final config = _typeConfig(alert.type);

    return InkWell(
      onTap: () => Get.toNamed(Routes.RECEIVED_ALERT_DETAIL, arguments: ReceivedAlertDetailParameter(id: alert.id!)),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: padding(all: 14),
        decoration: BoxDecoration(
          color: appTheme.whiteColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: config.color.withAlpha(18), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: config.color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(config.icon, color: config.color, size: 20.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3.h,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title ?? config.labelKey.tr,
                          style: StyleThemeData.size14Weight700(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        alert.createdAt?.formatTimeAgo ?? '---',
                        style: StyleThemeData.size10Weight400(color: appTheme.grayColor),
                      ),
                    ],
                  ),
                  if (alert.sender?.isNotEmpty == true)
                    Row(
                      spacing: 4.w,
                      children: [
                        Icon(Icons.person_outline_rounded, size: 12.w, color: appTheme.grayColor),
                        Text(
                          '${'receive_from'.tr} ${alert.sender}',
                          style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                        ),
                      ],
                    ),
                  if (alert.location?.isNotEmpty == true)
                    Row(
                      spacing: 4.w,
                      children: [
                        Icon(Icons.location_on_outlined, size: 12.w, color: appTheme.grayColor),
                        Expanded(
                          child: Text(
                            alert.location!,
                            style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (alert.speed != null)
                    Row(
                      spacing: 4.w,
                      children: [
                        Icon(Icons.speed_rounded, size: 12.w, color: config.color),
                        Text(
                          '${alert.speed?.toStringAsFixed(0)} km/h',
                          style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _AlertTypeConfig _typeConfig(int? type) {
    switch (type) {
      case 2:
        return _AlertTypeConfig(Icons.speed_rounded, appTheme.errorColor, 'noti_type_speed');
      case 3:
        return _AlertTypeConfig(Icons.pause_circle_outline_rounded, appTheme.secondaryColor, 'noti_type_stop');
      case 4:
        return _AlertTypeConfig(Icons.car_crash_outlined, appTheme.secondaryColor, 'noti_type_stop');
      default:
        return _AlertTypeConfig(Icons.notifications_outlined, appTheme.appColor, 'noti_type_default');
    }
  }
}

class _AlertTypeConfig {
  final IconData icon;
  final Color color;
  final String labelKey;
  const _AlertTypeConfig(this.icon, this.color, this.labelKey);
}
