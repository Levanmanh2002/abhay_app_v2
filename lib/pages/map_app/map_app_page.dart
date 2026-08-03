import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/traffic/road_sign_model.dart';
import 'package:abhay_app_v2/models/response/traffic/traffic_incident_model.dart';
import 'package:abhay_app_v2/resourese/service/map/road_sign_service.dart';
import 'package:abhay_app_v2/resourese/service/map/road_warning_service.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'map_app_controller.dart';

class MapAppPage extends GetWidget<MapAppController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: Stack(
        children: [
          // ─── Map ─────────────────────────────────────────────────────────
          Obx(() {
            final pos = controller.currentPosition.value;
            if (pos == null) return _buildLoading();

            return FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: LatLng(pos.latitude, pos.longitude),
                initialZoom: 16,
                minZoom: 5,
                maxZoom: 19,
                onPositionChanged: (_, __) => controller.isFollowing.value = false,
              ),
              children: [
                // Tile layer
                TileLayer(
                  urlTemplate: controller.tileUrl,
                  userAgentPackageName: 'com.chaitany.abhay',
                  maxZoom: 19,
                  errorTileCallback: (_, e, __) => debugPrint('[MAP] Tile: $e'),
                ),

                // Route polyline
                Obx(() {
                  if (controller.routePoints.length < 2) {
                    return const SizedBox.shrink();
                  }
                  return PolylineLayer(polylines: [
                    Polyline(
                      points: controller.routePoints,
                      strokeWidth: 4,
                      color: appTheme.appColor.withAlpha(200),
                    ),
                  ]);
                }),

                // Incident markers + Road sign markers
                Obx(() => MarkerLayer(
                      markers: [
                        // Current location
                        if (controller.currentPosition.value != null)
                          Marker(
                            point: LatLng(
                              controller.currentPosition.value!.latitude,
                              controller.currentPosition.value!.longitude,
                            ),
                            width: 56,
                            height: 56,
                            child: _buildLocationMarker(),
                          ),
                        // Traffic incidents
                        ...controller.incidents.map(
                          (i) => Marker(
                            point: i.position,
                            width: 40,
                            height: 40,
                            child: _buildIncidentMarker(i),
                          ),
                        ),
                        // Road signs từ OSM
                        ..._signService.signs.map(
                          (s) => Marker(
                            point: s.position,
                            width: 32,
                            height: 32,
                            child: _buildSignMarker(s),
                          ),
                        ),
                      ],
                    )),
              ],
            );
          }),

          // ─── Top bar ─────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: padding(horizontal: 16, top: 12),
                child: Row(
                  children: [
                    _iconBtn(icon: Icons.arrow_back_rounded, onTap: Get.back),
                    SizedBox(width: 10.w),
                    Expanded(child: Obx(() => _buildSpeedCard())),
                    SizedBox(width: 10.w),
                    Obx(() => _SpeedLimitBadge(
                          limit: controller.speedLimit.value,
                          isOver: controller.isOverTomtomLimit.value,
                        )),
                  ],
                ),
              ),
            ),
          ),

          // ─── Active warning banners ───────────────────────────────────────
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: Obx(() {
              final warnings = controller.activeWarnings;
              if (warnings.isEmpty) return const SizedBox.shrink();
              // Hiện tối đa 2 warning quan trọng nhất
              final shown = warnings.take(2).toList();
              return Column(
                spacing: 6.h,
                children: shown
                    .map((w) => _WarningBanner(
                          warning: w,
                          onDismiss: () => controller.dismissWarning(w.id),
                        ))
                    .toList(),
              );
            }),
          ),

          // ─── Road signs panel ─────────────────────────────────────────
          Obx(() {
            final signs = controller.nearbyRoadSigns;
            if (signs.isEmpty) return const SizedBox.shrink();
            return Positioned(
              bottom: 24,
              left: 16,
              right: 72,
              child: _RoadSignsPanel(signs: signs),
            );
          }),

          // ─── Bottom controls ──────────────────────────────────────────────
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10.h,
              children: [
                _iconBtn(
                  icon: Icons.my_location_rounded,
                  onTap: controller.centerOnMe,
                  color: appTheme.appColor,
                ),
                Obx(() {
                  if (controller.routePoints.length < 2) {
                    return const SizedBox.shrink();
                  }
                  return _iconBtn(
                    icon: Icons.clear_rounded,
                    onTap: controller.clearRoute,
                    color: appTheme.errorColor,
                  );
                }),
              ],
            ),
          ),

          // ─── Not tracking hint ────────────────────────────────────────────
          Obx(() {
            if (controller.isTracking.value) return const SizedBox.shrink();
            return Positioned(
              bottom: 24,
              left: 16,
              right: 72,
              child: Container(
                padding: padding(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: appTheme.secondaryColor.withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  spacing: 8.w,
                  children: [
                    Icon(Icons.info_outline_rounded, color: appTheme.whiteColor, size: 16.w),
                    Expanded(
                      child: Text('map_start_tracking_hint'.tr,
                          style: StyleThemeData.size12Weight400(color: appTheme.whiteColor)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Builders ─────────────────────────────────────────────────────────────

  RoadSignService get _signService => controller.signService;

  Widget _buildLoading() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            CircularProgressIndicator(color: appTheme.appColor),
            Text('map_locating'.tr, style: StyleThemeData.size14Weight400(color: appTheme.grayColor)),
          ],
        ),
      );

  Widget _buildSpeedCard() => Container(
        padding: padding(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: appTheme.whiteColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.speedStr,
                  style: StyleThemeData.size20Weight700(
                    color: controller.isOverSpeed.value || controller.isOverTomtomLimit.value
                        ? appTheme.errorColor
                        : appTheme.appColor,
                  ),
                ),
                Text('km/h', style: StyleThemeData.size10Weight400(color: appTheme.grayColor)),
              ],
            ),
            SizedBox(width: 12.w),
            Container(width: 1, height: 32, color: appTheme.grayE6Color),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                controller.locationText.value.isEmpty ? 'home_locating'.tr : controller.locationText.value,
                style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildLocationMarker() => Obx(() {
        final isTracking = controller.isTracking.value;
        return Stack(alignment: Alignment.center, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: isTracking ? 52 : 40,
            height: isTracking ? 52 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appTheme.appColor.withAlpha(isTracking ? 40 : 20),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appTheme.appColor,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: appTheme.appColor.withAlpha(80), blurRadius: 8, spreadRadius: 2),
              ],
            ),
          ),
        ]);
      });

  Widget _buildIncidentMarker(TrafficIncidentModel incident) {
    final color = _incidentColor(incident.category);
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(220),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withAlpha(80), blurRadius: 6, spreadRadius: 1),
        ],
      ),
      child: Center(
        child: Text(
          incident.category.emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Color _incidentColor(IncidentCategory cat) {
    switch (cat) {
      case IncidentCategory.accident:
        return const Color(0xFFDC2626);
      case IncidentCategory.roadClosed:
      case IncidentCategory.laneClosed:
        return const Color(0xFF7C3AED);
      case IncidentCategory.roadWorks:
        return const Color(0xFFD97706);
      case IncidentCategory.jam:
        return const Color(0xFFEA580C);
      case IncidentCategory.dangerousConditions:
      case IncidentCategory.ice:
      case IncidentCategory.flooding:
        return const Color(0xFF0891B2);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildSignMarker(RoadSignModel sign) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(sign.emoji, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: appTheme.whiteColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Icon(icon, size: 20.w, color: color ?? appTheme.blackColor),
        ),
      );
}

// ─── Speed limit badge ────────────────────────────────────────────────────────

class _SpeedLimitBadge extends StatelessWidget {
  const _SpeedLimitBadge({required this.limit, required this.isOver});

  final double limit;
  final bool isOver;

  @override
  Widget build(BuildContext context) {
    final show = limit > 0;
    final borderColor = isOver
        ? const Color(0xFFDC2626)
        : show
            ? const Color(0xFFE53E3E)
            : Colors.grey.shade300;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOver ? const Color(0xFFDC2626) : Colors.white,
        border: Border.all(color: borderColor, width: 3.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isOver ? 40 : 20), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(
          show ? '${limit.toInt()}' : '--',
          style: TextStyle(
            fontSize: show ? 13 : 11,
            fontWeight: FontWeight.w800,
            color: isOver ? Colors.white : const Color(0xFF1A202C),
          ),
        ),
      ),
    );
  }
}

// ─── Warning banner ───────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({
    required this.warning,
    required this.onDismiss,
  });

  final RoadWarning warning;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final config = _config(warning.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: config.iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(config.icon, size: 20, color: config.titleColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: config.titleColor,
                  ),
                ),
                if (warning.detail.isNotEmpty)
                  Text(
                    warning.detail,
                    style: TextStyle(fontSize: 11, color: config.subtitleColor),
                  ),
                if (warning.distanceM > 0)
                  Text(
                    'Còn ${warning.distanceM.toInt()}m',
                    style: TextStyle(fontSize: 10, color: config.subtitleColor),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, size: 18, color: config.titleColor),
          ),
        ],
      ),
    );
  }

  _BannerConfig _config(RoadWarningType type) {
    switch (type) {
      case RoadWarningType.speedLimitExceeded:
        return const _BannerConfig(
          icon: Icons.speed_rounded,
          bgColor: Color(0xFFFFF5F5),
          borderColor: Color(0xFFFEB2B2),
          iconBg: Color(0xFFFED7D7),
          titleColor: Color(0xFF742A2A),
          subtitleColor: Color(0xFF9B2C2C),
        );
      case RoadWarningType.incident:
        return const _BannerConfig(
          icon: Icons.car_crash_rounded,
          bgColor: Color(0xFFFFF5F5),
          borderColor: Color(0xFFFEB2B2),
          iconBg: Color(0xFFFED7D7),
          titleColor: Color(0xFF742A2A),
          subtitleColor: Color(0xFF9B2C2C),
        );
      case RoadWarningType.hazard:
        return const _BannerConfig(
          icon: Icons.warning_amber_rounded,
          bgColor: Color(0xFFEBF8FF),
          borderColor: Color(0xFFBEE3F8),
          iconBg: Color(0xFFBEE3F8),
          titleColor: Color(0xFF2A4365),
          subtitleColor: Color(0xFF2C5282),
        );
      case RoadWarningType.roadWork:
        return const _BannerConfig(
          icon: Icons.construction_rounded,
          bgColor: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFBD38D),
          iconBg: Color(0xFFFEF08A),
          titleColor: Color(0xFF744210),
          subtitleColor: Color(0xFF92400E),
        );
      case RoadWarningType.trafficJam:
        return const _BannerConfig(
          icon: Icons.traffic_rounded,
          bgColor: Color(0xFFFFF7ED),
          borderColor: Color(0xFFFDBA74),
          iconBg: Color(0xFFFED7AA),
          titleColor: Color(0xFF7C2D12),
          subtitleColor: Color(0xFF9A3412),
        );
    }
  }
}

class _BannerConfig {
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconBg;
  final Color titleColor;
  final Color subtitleColor;

  const _BannerConfig({
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconBg,
    required this.titleColor,
    required this.subtitleColor,
  });
}

// ─── Road signs panel ─────────────────────────────────────────────────────────

class _RoadSignsPanel extends StatelessWidget {
  const _RoadSignsPanel({required this.signs});

  final List<RoadSignModel> signs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(245),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.signpost_rounded, size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 5),
              Text(
                'Biển báo gần đây',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: signs.take(6).map((s) => _SignChip(sign: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SignChip extends StatelessWidget {
  const _SignChip({required this.sign});

  final RoadSignModel sign;

  Color _chipColor() {
    switch (sign.type) {
      case RoadSignType.speedLimit:
        return const Color(0xFFDC2626);
      case RoadSignType.speedBump:
        return const Color(0xFFD97706);
      case RoadSignType.trafficSignal:
        return const Color(0xFF059669);
      case RoadSignType.stopSign:
        return const Color(0xFFDC2626);
      case RoadSignType.schoolZone:
        return const Color(0xFF7C3AED);
      case RoadSignType.hospitalZone:
        return const Color(0xFF0891B2);
      case RoadSignType.roadWork:
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sign.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sign.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                if (sign.value != null)
                  Text(
                    sign.value ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withAlpha(180),
                    ),
                  ),
                Text(
                  '${sign.distanceM.toInt()}m',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
