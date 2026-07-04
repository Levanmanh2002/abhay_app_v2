import 'dart:convert';

import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:http/http.dart' as http;

/// TomTom Snap-to-Roads API — lấy speed limit tại vị trí hiện tại.
///
/// API yêu cầu tối thiểu 2 điểm (snap một đoạn đường).
/// → Lưu điểm trước, gửi [điểm trước, điểm hiện tại] mỗi lần gọi.
/// → Throttle: chỉ gọi khi đi thêm >= [minDistanceM].
class TomTomService {
  static const double minDistanceM = 80.0;

  // Buffer 2 điểm gần nhất
  _GeoPoint? _prevPoint;
  _GeoPoint? _lastPoint;

  bool _isRequesting = false;

  Future<double> getSpeedLimit(double lat, double lng) async {
    final key = AppConstants.keySpeedLimit.trim();
    if (key.isEmpty) return 0;
    if (_isRequesting) return 0;

    final current = _GeoPoint(lat, lng);

    // Lần đầu — chưa có điểm trước, lưu lại và chờ lần sau
    if (_lastPoint == null) {
      _lastPoint = current;
      return 0;
    }

    // Throttle theo khoảng cách
    final dist = _distanceM(_lastPoint!.lat, _lastPoint!.lng, lat, lng);
    if (dist < minDistanceM) return 0;

    _prevPoint = _lastPoint;
    _lastPoint = current;

    _isRequesting = true;
    try {
      final uri = Uri.parse('${AppConstants.urlSpeedLimit}?key=$key');

      // Snap-to-Roads cần >= 2 điểm — gửi [điểm trước, điểm hiện tại]
      final body = jsonEncode({
        'points': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [_prevPoint!.lng, _prevPoint!.lat],
            },
          },
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [current.lng, current.lat],
            },
          },
        ]
      });

      loggerHelper.logBlue('[TOMTOM] Request: ${uri.toString()} → ${jsonEncode(body)}');

      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        loggerHelper.error('[TOMTOM] HTTP ${resp.statusCode}: ${resp.body}');
        return 0;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final snappedPoints = data['snappedPoints'] as List<dynamic>?;
      if (snappedPoints == null || snappedPoints.isEmpty) return 0;

      // Lấy speed limit từ điểm cuối (vị trí hiện tại)
      final last = snappedPoints.last as Map<String, dynamic>;
      final speedLimit = last['speedLimit'] as Map<String, dynamic>?;
      if (speedLimit == null) return 0;

      final value = (speedLimit['value'] as num?)?.toDouble() ?? 0;
      final unit = speedLimit['unit'] as String? ?? 'KMPH';
      final kmh = unit == 'MPH' ? value * 1.60934 : value;

      if (kmh > 0) {
        loggerHelper.logBlue('[TOMTOM] Speed limit: ${kmh.toInt()} km/h');
      }

      return kmh;
    } catch (e) {
      loggerHelper.error('[TOMTOM] Error: $e');
      return 0;
    } finally {
      _isRequesting = false;
    }
  }

  void reset() {
    _prevPoint = null;
    _lastPoint = null;
    _isRequesting = false;
  }

  static double _distanceM(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * 0.017453292519943295;
    final dLng = (lng2 - lng1) * 0.017453292519943295;
    final a = _sq(dLat / 2) + _cos(lat1 * 0.017453292519943295) * _cos(lat2 * 0.017453292519943295) * _sq(dLng / 2);
    return 2 * r * _asin(_sqrt(a));
  }

  static double _sq(double x) => x * x;
  static double _cos(double x) => 1 - x * x / 2 + x * x * x * x / 24;
  static double _asin(double x) {
    if (x >= 1) return 1.5707963267948966;
    return x + x * x * x / 6 + 3 * x * x * x * x * x / 40;
  }

  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double g = x / 2;
    for (int i = 0; i < 20; i++) g = (g + x / g) / 2;
    return g;
  }
}

class _GeoPoint {
  final double lat;
  final double lng;
  const _GeoPoint(this.lat, this.lng);
}
