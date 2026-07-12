import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/loading_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'received_alert_detail_controller.dart';

class ReceivedAlertDetailPage extends GetWidget<ReceivedAlertDetailController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'received_alert_detail_title'.tr,
        isBackIconCustom: true,
        backgroundColor: appTheme.background,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        final alert = controller.alertDetail.value;

        if (alert == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTheme.appColor.withAlpha(15),
                  ),
                  child: Icon(Icons.notifications_off_outlined, size: 32.w, color: appTheme.appColor),
                ),
                SizedBox(height: 16.h),
                Text(
                  'received_alert_detail_empty'.tr,
                  style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                ),
              ],
            ),
          );
        }

        final typeConfig = _typeConfig(alert.type);

        return SingleChildScrollView(
          padding: padding(horizontal: 16, top: 16, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16.h,
            children: [
              // Sender row
              Row(
                spacing: 12.w,
                children: [
                  CircleAvatar(
                    radius: 24.w,
                    backgroundColor: appTheme.appColor.withAlpha(20),
                    child: Text(
                      _initial(alert.sender),
                      style: StyleThemeData.size18Weight700(color: appTheme.appColor),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3.h,
                    children: [
                      Text(alert.sender ?? 'Unknown', style: StyleThemeData.size16Weight700()),
                      Text(
                        _formatDate(alert.createdAt),
                        style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                      ),
                    ],
                  ),
                ],
              ),

              // Alert card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: appTheme.whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: typeConfig.color.withAlpha(18), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: padding(horizontal: 20, top: 24, bottom: 20),
                      child: Column(
                        spacing: 16.h,
                        children: [
                          // Title
                          Text(
                            typeConfig.title.tr,
                            style: StyleThemeData.size20Weight700(color: appTheme.blackColor),
                            textAlign: TextAlign.center,
                          ),

                          // Location
                          if (alert.location?.isNotEmpty == true)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8.w,
                              children: [
                                Icon(Icons.location_on_rounded, size: 20.w, color: appTheme.appColor),
                                Expanded(
                                  child: Text(
                                    alert.location!,
                                    style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                          // Speed
                          if (alert.speed != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8.w,
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appTheme.grayE6Color, width: 1.5),
                                  ),
                                  child: Icon(Icons.speed_rounded, size: 20.w, color: appTheme.gray86Color),
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: alert.speed!.toStringAsFixed(1),
                                      style: StyleThemeData.size36Weight700(color: typeConfig.color),
                                    ),
                                    TextSpan(
                                      text: ' km/h',
                                      style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                                    ),
                                  ]),
                                ),
                              ],
                            ),

                          // Warning banner
                          Container(
                            width: double.infinity,
                            padding: padding(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: typeConfig.color.withAlpha(15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 8.w,
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 18.w, color: typeConfig.color),
                                Text(
                                  typeConfig.message.tr,
                                  style: StyleThemeData.size14Weight700(color: typeConfig.color),
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
                        borderRadius:
                            const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                        child: SizedBox(
                          height: 220.h,
                          child: Stack(
                            children: [
                              _AlertMap(lat: alert.lat!, lng: alert.lng!),
                              if (alert.speedLimit != null && alert.speedLimit! > 0)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: _SpeedLimitBadge(limit: alert.speedLimit!),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _initial(String? name) => (name?.trim().isNotEmpty == true) ? name![0].toUpperCase() : '?';

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      p(int n) => n.toString().padLeft(2, '0');
      return 'At: ${p(dt.day)}/${p(dt.month)}/${dt.year} - ${p(dt.hour)}:${p(dt.minute)}';
    } catch (_) {
      return raw;
    }
  }

  _TypeConfig _typeConfig(int? type) {
    switch (type) {
      case 1:
        return const _TypeConfig(Color(0xFFDC2626), 'alert_type_sos', 'alert_msg_sos');
      case 2:
        return const _TypeConfig(Color(0xFFDC2626), 'alert_title_speed', 'alert_msg_speed');
      case 3:
        return const _TypeConfig(Color(0xFFD97706), 'alert_title_sudden_stop', 'alert_msg_sudden_stop');
      case 4:
        return const _TypeConfig(Color(0xFF7C3AED), 'alert_title_stopped', 'alert_msg_stopped');
      default:
        return const _TypeConfig(Color(0xFF6B7280), 'alert_type_unknown', 'alert_msg_unknown');
    }
  }
}

class _TypeConfig {
  final Color color;
  final String title;
  final String message;
  const _TypeConfig(this.color, this.title, this.message);
}

class _SpeedLimitBadge extends StatelessWidget {
  const _SpeedLimitBadge({required this.limit});
  final int limit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE53E3E), width: 4),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 8)],
      ),
      child: Center(
        child: Text(
          '$limit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A202C)),
        ),
      ),
    );
  }
}

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
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.chaitany.abhay',
        ),
        MarkerLayer(markers: [
          Marker(
            point: point,
            width: 40,
            height: 48,
            child: const Icon(Icons.location_pin, color: Color(0xFFDC2626), size: 44),
          ),
        ]),
      ],
    );
  }
}
