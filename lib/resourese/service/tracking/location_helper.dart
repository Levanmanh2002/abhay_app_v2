import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Chuyển tọa độ → tên đường/địa chỉ.
///
/// Có throttle: chỉ geocode khi di chuyển > [minDistanceMeters]
/// hoặc khi chưa từng geocode.
class LocationHelper {
  static const double _minDistanceMeters = 100.0;

  Position? _lastGeocodedPosition;
  String _lastAddress = '';

  /// Trả về địa chỉ rút gọn từ tọa độ, hoặc địa chỉ cũ nếu chưa đến
  /// ngưỡng khoảng cách cần geocode lại.
  Future<String> getAddress(Position position) async {
    final shouldUpdate = _lastGeocodedPosition == null ||
        Geolocator.distanceBetween(
              _lastGeocodedPosition!.latitude,
              _lastGeocodedPosition!.longitude,
              position.latitude,
              position.longitude,
            ) >=
            _minDistanceMeters;

    if (!shouldUpdate) return _lastAddress;

    _lastGeocodedPosition = position;
    _lastAddress = await _geocode(position.latitude, position.longitude);
    return _lastAddress;
  }

  /// Geocode thẳng không cache (dùng cho background task)
  static Future<String> geocode(double lat, double lng) =>
      _geocode(lat, lng);

  static Future<String> _geocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return '';
      final p = placemarks.first;

      // Lấy thông tin có giá trị nhất: street, subLocality, locality
      final parts = [
        p.street,
        p.subLocality,
        p.locality,
      ].where((s) => s != null && s.isNotEmpty).toList();

      return parts.take(2).join(', ');
    } catch (_) {
      return '';
    }
  }

  void reset() {
    _lastGeocodedPosition = null;
    _lastAddress = '';
  }
}
