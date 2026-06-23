import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  static LocationService get to => Get.find();

  Position? _cachedPosition;
  StreamSubscription<Position>? _positionStream;

  Position? get currentPosition => _cachedPosition;

  Position get positionOrDefault =>
      _cachedPosition ??
      Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
      );

  @override
  void onInit() {
    super.onInit();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final position = await _fetchPosition();
    if (position != null) {
      _cachedPosition = position;
    }

    _startTracking();
  }

  Future<Position?> _fetchPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0),
      ).timeout(
        const Duration(seconds: 10), // ✅ Timeout tránh chờ quá lâu trên máy cũ
        onTimeout: () async {
          try {
            return await Geolocator.getLastKnownPosition() ?? Future.error('timeout');
          } catch (_) {
            return Future.error('timeout');
          }
        },
      );
    } catch (_) {
      // ✅ Thử lấy last known position nếu fail
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  void _startTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;

    if (!await Geolocator.isLocationServiceEnabled()) return;

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // ✅ Chỉ update khi di chuyển >= 10m
      ),
    ).listen((position) => _cachedPosition = position, onError: (_) {});
  }

  Future<Position?> getPosition() async {
    if (_cachedPosition != null) return _cachedPosition;
    final position = await _fetchPosition();
    if (position != null) _cachedPosition = position;
    return _cachedPosition;
  }

  @override
  void onClose() {
    _positionStream?.cancel();
    super.onClose();
  }
}

// // Lấy cache ngay — không async, không chờ
// final position = LocationService.to.positionOrDefault;

// // Lấy có await — trả cache nếu có, fetch nếu chưa
// final position = await LocationService.to.getPosition();
