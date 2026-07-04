import 'dart:async';

import 'package:abhay_app_v2/models/response/traffic/road_sign_model.dart';
import 'package:abhay_app_v2/models/response/traffic/traffic_incident_model.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/resourese/service/map/road_sign_service.dart';
import 'package:abhay_app_v2/resourese/service/map/road_warning_service.dart';
import 'package:abhay_app_v2/resourese/service/map/tom_tom_service.dart';
import 'package:abhay_app_v2/resourese/service/tracking/tracking_service.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapAppController extends GetxController {
  late final TrackingService _trackingService;
  final _tomtom = TomTomService();
  final _warningService = RoadWarningService();
  final _signService = RoadSignService();
  RoadSignService get signService => _signService;

  final mapController = MapController();

  // ─── Reactive state ───────────────────────────────────────────────────────
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxDouble speedLimit = 0.0.obs;
  final RxBool isFollowing = true.obs;

  // Road warnings (incidents + speed limit)
  final RxList<TrafficIncidentModel> incidents = <TrafficIncidentModel>[].obs;
  final RxList<RoadWarning> activeWarnings = <RoadWarning>[].obs;
  final RxBool isOverTomtomLimit = false.obs;

  // Road signs (OSM)
  final RxList<RoadSignModel> nearbyRoadSigns = <RoadSignModel>[].obs;

  // Delegate từ TrackingService
  RxDouble get speed => _trackingService.speed;
  RxBool get isTracking => _trackingService.isTracking;
  RxBool get isOverSpeed => _trackingService.isOverSpeed;
  RxString get locationText => _trackingService.locationText;

  String get speedStr => speed.value.toStringAsFixed(0);
  String get tomtomKey => AppConstants.tomtomApiKey;

  String get tileUrl {
    final key = tomtomKey;
    if (key.isNotEmpty && key != 'YOUR_TOMTOM_API_KEY_HERE') {
      return 'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key=$key';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  StreamSubscription<Position>? _positionSub;
  bool _isAutoDetect = false;

  @override
  void onInit() {
    super.onInit();
    _trackingService = Get.find<TrackingService>();

    // Init warning service với Traffic API key
    _warningService.init(AppConstants.keySpeedLimit);

    // Sync auto-detect từ user settings
    if (Get.isRegistered<ProfileController>()) {
      final user = Get.find<ProfileController>().userModel.value;
      if (user != null) {
        _isAutoDetect = (user.isAutoDetectSpeedLimit ?? 0) == 1;
      }
    }

    _initPosition();
    _startListening();
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    _warningService.reset();
    _signService.reset();
    super.onClose();
  }

  // ─── Init position ────────────────────────────────────────────────────────

  Future<void> _initPosition() async {
    try {
      var pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      currentPosition.value = pos;
      debugPrint('[MAP] Init: ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      debugPrint('[MAP] Init error: $e');
    }
  }

  // ─── GPS stream ───────────────────────────────────────────────────────────

  void _startListening() {
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      _onPosition,
      onError: (e) => debugPrint('[MAP] GPS error: $e'),
      cancelOnError: false,
    );
  }

  Future<void> _onPosition(Position pos) async {
    currentPosition.value = pos;

    // Ghi lộ trình
    if (isTracking.value) {
      routePoints.add(LatLng(pos.latitude, pos.longitude));
      if (routePoints.length > 500) {
        routePoints.removeRange(0, routePoints.length - 500);
      }
    }

    // Auto-pan
    if (isFollowing.value) {
      try {
        mapController.move(
          LatLng(pos.latitude, pos.longitude),
          mapController.camera.zoom,
        );
      } catch (_) {}
    }

    // TomTom speed limit
    if (_isAutoDetect) {
      final limit = await _tomtom.getSpeedLimit(pos.latitude, pos.longitude);
      if (limit > 0) speedLimit.value = limit;
    }

    // Road warnings
    await _warningService.update(
      lat: pos.latitude,
      lng: pos.longitude,
      speedKmh: speed.value,
      tomtomLimit: _isAutoDetect ? speedLimit.value : 0,
    );

    // Road signs (OSM Overpass)
    await _signService.update(pos.latitude, pos.longitude);

    // Sync reactive state
    incidents.value = _warningService.incidents;
    activeWarnings.value = _warningService.activeWarnings;
    isOverTomtomLimit.value = _warningService.isOverTomtomLimit;
    nearbyRoadSigns.value = _signService.nearbySignsAt(pos.latitude, pos.longitude);
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void centerOnMe() {
    final pos = currentPosition.value;
    if (pos == null) return;
    isFollowing.value = true;
    mapController.move(LatLng(pos.latitude, pos.longitude), 16);
  }

  void clearRoute() => routePoints.clear();

  void setAutoDetect(bool value) {
    _isAutoDetect = value;
    if (!value) {
      speedLimit.value = 0;
      _tomtom.reset();
    }
  }

  void dismissWarning(String id) {
    activeWarnings.removeWhere((w) => w.id == id);
  }
}
