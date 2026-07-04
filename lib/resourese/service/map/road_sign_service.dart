import 'dart:convert';
import 'dart:math';

import 'package:abhay_app_v2/models/response/traffic/road_sign_model.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Lấy biển báo / đặc điểm đường xung quanh vị trí hiện tại.
///
/// Dùng TomTom Search Nearby API (key đã có).
/// Categories:
///   9930 = Traffic control (đèn tín hiệu, biển báo)
///   7372 = Trường học
///   7321 = Bệnh viện / phòng khám
///   7311 = Cảnh sát (khu vực kiểm soát tốc độ)
///   9927 = Speed bump / gờ giảm tốc
class RoadSignService {
  static const double _queryRadiusM = 200.0;
  static const double _displayRadiusM = 150.0;
  static const double _refetchDistM = 100.0;

  double? _lastLat;
  double? _lastLng;
  bool _isFetching = false;

  final List<RoadSignModel> _signs = [];

  List<RoadSignModel> get signs => List.unmodifiable(_signs);

  List<RoadSignModel> nearbySignsAt(double lat, double lng) {
    return _signs
        .map((s) => RoadSignModel(
              id: s.id,
              position: s.position,
              type: s.type,
              label: s.label,
              value: s.value,
              distanceM: _dist(lat, lng, s.position.latitude, s.position.longitude),
            ))
        .where((s) => s.distanceM <= _displayRadiusM)
        .toList()
      ..sort((a, b) => a.distanceM.compareTo(b.distanceM));
  }

  void reset() {
    _signs.clear();
    _lastLat = null;
    _lastLng = null;
  }

  Future<void> update(double lat, double lng) async {
    if (_isFetching) return;
    final shouldFetch = _lastLat == null || _dist(_lastLat!, _lastLng!, lat, lng) >= _refetchDistM;
    if (!shouldFetch) return;
    _isFetching = true;
    try {
      await _fetch(lat, lng);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _fetch(double lat, double lng) async {
    final key = AppConstants.keySpeedLimit.trim();
    if (key.isEmpty) return;

    // TomTom Nearby Search — nhiều category cùng lúc
    final uri = Uri(
      scheme: 'https',
      host: 'api.tomtom.com',
      path: '/search/2/nearbySearch/.json',
      queryParameters: {
        'key': key,
        'lat': lat.toString(),
        'lon': lng.toString(),
        'radius': _queryRadiusM.toInt().toString(),
        'categorySet': '9930,7372,7321,7311,9927',
        'limit': '20',
        'language': 'en-GB',
      },
    );

    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));

      if (resp.statusCode != 200) {
        loggerHelper.error('[SIGNS] HTTP ${resp.statusCode}');
        return;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      final parsed = <RoadSignModel>[];
      for (final r in results) {
        final sign = _parseResult(r as Map<String, dynamic>, lat, lng);
        if (sign != null) parsed.add(sign);
      }

      _signs
        ..clear()
        ..addAll(parsed);
      _lastLat = lat;
      _lastLng = lng;

      loggerHelper.logBlue('[SIGNS] Found ${_signs.length} signs nearby');
    } catch (e) {
      loggerHelper.error('[SIGNS] Error: $e');
    }
  }

  RoadSignModel? _parseResult(Map<String, dynamic> r, double myLat, double myLng) {
    final id = r['id']?.toString() ?? '';
    final poi = r['poi'] as Map<String, dynamic>? ?? {};
    final position = r['position'] as Map<String, dynamic>? ?? {};
    final elLat = (position['lat'] as num?)?.toDouble() ?? 0;
    final elLng = (position['lon'] as num?)?.toDouble() ?? 0;
    final dist = (r['dist'] as num?)?.toDouble() ?? _dist(myLat, myLng, elLat, elLng);

    final name = poi['name'] as String? ?? '';
    final catSet = (poi['categorySet'] as List<dynamic>?)?.map((c) => (c as Map)['id'] as int? ?? 0).toList() ?? [];
    final categories = (poi['categories'] as List<dynamic>?)?.cast<String>() ?? [];

    final catId = catSet.isNotEmpty ? catSet.first : 0;

    // Map category → RoadSignType
    switch (catId) {
      case 9930:
        // Traffic control — đèn, biển báo
        final isSignal =
            categories.any((c) => c.toLowerCase().contains('signal') || c.toLowerCase().contains('traffic'));
        return RoadSignModel(
          id: id,
          position: _pos(elLat, elLng),
          type: isSignal ? RoadSignType.trafficSignal : RoadSignType.unknown,
          label: isSignal ? 'Đèn tín hiệu giao thông' : name,
          distanceM: dist,
        );

      case 9927:
        return RoadSignModel(
          id: id,
          position: _pos(elLat, elLng),
          type: RoadSignType.speedBump,
          label: 'Gờ giảm tốc',
          distanceM: dist,
        );

      case 7372:
        return RoadSignModel(
          id: id,
          position: _pos(elLat, elLng),
          type: RoadSignType.schoolZone,
          label: 'Trường học',
          value: name.isNotEmpty ? name : null,
          distanceM: dist,
        );

      case 7321:
        return RoadSignModel(
          id: id,
          position: _pos(elLat, elLng),
          type: RoadSignType.hospitalZone,
          label: 'Bệnh viện / Phòng khám',
          value: name.isNotEmpty ? name : null,
          distanceM: dist,
        );

      case 7311:
        return RoadSignModel(
          id: id,
          position: _pos(elLat, elLng),
          type: RoadSignType.unknown,
          label: 'Khu vực cảnh sát',
          value: name.isNotEmpty ? name : null,
          distanceM: dist,
        );

      default:
        return null;
    }
  }

  static LatLng _pos(double lat, double lng) => LatLng(lat, lng);

  static double _dist(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * asin(sqrt(a));
  }
}
