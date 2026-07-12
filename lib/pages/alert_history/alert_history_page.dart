import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/pages/alert_history/alert_history_controller.dart';
import 'package:abhay_app_v2/resourese/service/location_service.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/launch_url.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AlertHistoryPage extends GetWidget<AlertHistoryController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'alert_history_title'.tr,
        isBackIconCustom: true,
        backgroundColor: appTheme.background,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Skeletonizer(
            child: ListView.separated(
              padding: padding(horizontal: 16, vertical: 16),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (_, __) => _AlertCard(
                alert: NotiAlertModel(
                  type: 2,
                  location: 'Đ. Nguyễn Tất Thành, Vietnam',
                  speed: 60,
                  sound: 75,
                  speedLimit: 40,
                  createdAt: '2025-01-01T10:00:00',
                ),
              ),
            ),
          );
        }

        if (controller.alerts.isEmpty) {
          return _buildEmpty();
        }

        return RefreshIndicator(
          color: appTheme.appColor,
          onRefresh: controller.fetchHistory,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding(horizontal: 16, vertical: 16),
            itemCount: controller.alerts.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (_, i) {
              if (i == controller.alerts.length) {
                return Padding(
                  padding: padding(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(color: appTheme.appColor),
                  ),
                );
              }

              // Load more khi gần cuối
              if (i == controller.alerts.length - 3) {
                WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadMore());
              }

              return _AlertCard(alert: controller.alerts[i]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12.h,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: appTheme.appColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, size: 32.w, color: appTheme.appColor),
          ),
          Text(
            'alert_history_empty'.tr,
            style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
          ),
        ],
      ),
    );
  }
}

// ─── Alert Card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final NotiAlertModel alert;

  @override
  Widget build(BuildContext context) {
    final typeConfig = _typeConfig(alert.type);

    return InkWell(
      onTap: () async {
        final determinePosition = await LocationService.to.getPosition();

        launchMapsDirURl(
          start: '${determinePosition?.latitude}, ${determinePosition?.longitude}',
          end: '${alert.lat ?? ''}, ${alert.lng ?? ''}',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: typeConfig.color.withAlpha(15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: padding(horizontal: 16, top: 16, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.h,
                children: [
                  // Date + recipient row
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14.w, color: appTheme.grayColor),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(alert.createdAt),
                        style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                      ),
                      const Spacer(),
                      // Type badge
                      Container(
                        padding: padding(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeConfig.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4.w,
                          children: [
                            Icon(typeConfig.icon, size: 11.w, color: typeConfig.color),
                            Text(
                              typeConfig.label.tr,
                              style: StyleThemeData.size10Weight700(color: typeConfig.color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Location
                  if (alert.location?.isNotEmpty == true)
                    Row(
                      spacing: 5.w,
                      children: [
                        Icon(Icons.location_on_rounded, size: 14.w, color: appTheme.appColor),
                        Expanded(
                          child: Text(
                            alert.location!,
                            style: StyleThemeData.size14Weight700(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  // Speed + Sound row
                  Row(
                    spacing: 16.w,
                    children: [
                      _MetricChip(
                        icon: Icons.speed_rounded,
                        value: '${alert.speed?.toStringAsFixed(2) ?? '--'} km/h',
                        color: appTheme.appColor,
                      ),
                      _MetricChip(
                        icon: Icons.volume_up_rounded,
                        value: '${alert.sound?.toStringAsFixed(2) ?? '--'} dB',
                        color: const Color(0xFFFF6B35),
                      ),
                    ],
                  ),

                  // Warning message
                  Container(
                    width: double.infinity,
                    padding: padding(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: typeConfig.color.withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: typeConfig.color.withAlpha(40)),
                    ),
                    child: Row(
                      spacing: 6.w,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14.w, color: typeConfig.color),
                        Expanded(
                          child: Text(
                            typeConfig.message.tr,
                            style: StyleThemeData.size12Weight700(color: typeConfig.color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Map
            if (alert.lat != null && alert.lng != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 180.h,
                  child: _AlertMap(lat: alert.lat!, lng: alert.lng!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      pad(int n) => n.toString().padLeft(2, '0');
      return 'At: ${dt.year}-${pad(dt.month)}-${pad(dt.day)} '
          '${pad(dt.hour)}:${pad(dt.minute)}';
    } catch (_) {
      return raw;
    }
  }

  _TypeConfig _typeConfig(int? type) {
    switch (type) {
      case 1:
        return const _TypeConfig(
          Icons.sos_rounded,
          Color(0xFFDC2626),
          'alert_type_sos',
          'alert_msg_sos',
        );
      case 2:
        return const _TypeConfig(
          Icons.speed_rounded,
          Color(0xFFDC2626),
          'alert_type_speed',
          'alert_msg_speed',
        );
      case 3:
        return const _TypeConfig(
          Icons.pause_circle_outline_rounded,
          Color(0xFFD97706),
          'alert_type_sudden_stop',
          'alert_msg_sudden_stop',
        );
      case 4:
        return const _TypeConfig(
          Icons.stop_circle_outlined,
          Color(0xFF7C3AED),
          'alert_type_stopped',
          'alert_msg_stopped',
        );
      default:
        return const _TypeConfig(
          Icons.notifications_outlined,
          Color(0xFF6B7280),
          'alert_type_unknown',
          'alert_msg_unknown',
        );
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color color;
  final String label;
  final String message;
  const _TypeConfig(this.icon, this.color, this.label, this.message);
}

// ─── Metric chip ──────────────────────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5.w,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(40), width: 1.5),
          ),
          child: Icon(icon, size: 14.w, color: color),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.w,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }
}

// ─── Alert map (flutter_map mini) ────────────────────────────────────────────

class _AlertMap extends StatelessWidget {
  const _AlertMap({required this.lat, required this.lng});
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);
    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none, // non-interactive thumbnail
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.chaitany.abhay',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 36,
              height: 44,
              child: const Icon(
                Icons.location_pin,
                color: Color(0xFFDC2626),
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
