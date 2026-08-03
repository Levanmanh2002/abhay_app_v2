import 'dart:convert';
import 'dart:math' as math;

import 'package:abhay_app_v2/models/response/traffic/road_ahead_model.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:http/http.dart' as http;

/// TomTom **Snap to Roads API v1** — lấy giới hạn tốc độ đoạn đường đang đi,
/// giới hạn tốc độ sắp tới, và biển báo giao thông phía trước.
///
/// Khác biệt so với bản cũ (bản cũ parse theo schema Google Roads API nên luôn
/// trả 0):
///   1. Endpoint đúng: `https://api.tomtom.com/snapToRoads/1`
///      (KHÔNG phải `/snap-to-roads/1/snap-to-roads`).
///   2. BẮT BUỘC gửi tham số `fields` — mặc định API chỉ trả geometry,
///      không có speedLimits/trafficSigns.
///   3. Response đúng là `route[].properties.speedLimits` và
///      `route[].properties.trafficSigns`, KHÔNG phải `snappedPoints[].speedLimit`.
///   4. `measurementSystem=metric` để luôn nhận `kmph`, khỏi phải quy đổi.
///
/// Chiến lược gọi:
///   - Giữ buffer các điểm GPS gần nhất (trace) để API map-match chính xác
///     thay vì chỉ gửi 2 điểm.
///   - Thêm 1 điểm chiếu về phía trước theo heading → API dựng lại luôn cả
///     đoạn đường sắp tới, `route[]` sau routeIndex hiện tại chính là "phía trước".
///   - 1 request duy nhất trả cả current + ahead (bản cũ gọi 2 request).
class TomTomService {
  // ─── Cấu hình ─────────────────────────────────────────────────────────────

  /// Chỉ gọi lại API khi đã đi thêm quãng đường này.
  static const double refetchDistanceM = 80.0;

  /// Khoảng cách chiếu về phía trước để "nhìn trước" đoạn đường sắp tới.
  static const double defaultLookaheadM = 250.0;

  /// Số điểm GPS tối đa giữ trong trace (API cho phép tới 5000, ta chỉ cần vài điểm).
  static const int _maxTracePoints = 8;

  /// Khoảng cách tối thiểu giữa 2 điểm trong trace — quá gần thì map-matching
  /// không thêm thông tin mà chỉ làm request nặng hơn.
  static const double _minTraceSpacingM = 20.0;

  /// Ngưỡng coi 1 điểm là off-road. Tăng lên 100 (max cho hệ mét) để điểm chiếu
  /// phía trước vẫn match được khi đường cong.
  static const int _offroadMarginM = 100;

  /// Fields cần lấy. Không được có khoảng trắng, không được có object rỗng `{}`.
  static const String _fields = '{'
      'projectedPoints{properties{routeIndex,snapResult}},'
      'route{properties{'
      'id,'
      'speedLimits{value,unit,type},'
      'trafficSigns{signType,chainage,unit},'
      'traveledDistance{value,unit},'
      'address{roadName},'
      'emissionRegulations{restrictionType,engineType}'
      '}}'
      '}';

  // ─── State ────────────────────────────────────────────────────────────────

  final List<_TracePoint> _trace = [];
  double? _lastFetchLat;
  double? _lastFetchLng;
  bool _isRequesting = false;

  /// Kết quả gần nhất — trả lại khi đang throttle để caller luôn có dữ liệu.
  RoadAheadResult? _lastResult;
  RoadAheadResult? get lastResult => _lastResult;

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Gọi mỗi khi có điểm GPS mới (đã qua GpsFilter).
  ///
  /// Trả về `null` nếu chưa đủ điều kiện gọi API (đang throttle, chưa đủ điểm,
  /// thiếu key). Trả về [RoadAheadResult] khi có dữ liệu mới.
  ///
  /// [headingDeg] < 0 hoặc NaN nghĩa là không xác định — khi đó bỏ qua phần
  /// lookahead, chỉ lấy giới hạn tốc độ tại chỗ.
  Future<RoadAheadResult?> update({
    required double lat,
    required double lng,
    double headingDeg = -1,
    double speedKmh = 0,
    DateTime? timestamp,
    double lookaheadM = defaultLookaheadM,
  }) async {
    final key = AppConstants.keySpeedLimit.trim();
    if (key.isEmpty) {
      loggerHelper.error('[TOMTOM] KEY_SPEED_LIMIT rỗng — kiểm tra .env');
      return null;
    }

    _pushTrace(lat, lng, headingDeg, timestamp ?? DateTime.now());

    // Cần tối thiểu 2 điểm theo yêu cầu của API.
    if (_trace.length < 2) return null;
    if (_isRequesting) return null;

    // Throttle theo quãng đường đã đi.
    if (_lastFetchLat != null && _distanceM(_lastFetchLat!, _lastFetchLng!, lat, lng) < refetchDistanceM) {
      return null;
    }

    _isRequesting = true;
    try {
      // Chỉ chiếu điểm lookahead khi heading đáng tin (đang di chuyển đủ nhanh).
      final useLookahead = speedKmh > 10 && !headingDeg.isNaN && headingDeg >= 0;
      final points = <_TracePoint>[..._trace];
      if (useLookahead) {
        final projected = _project(lat, lng, headingDeg, lookaheadM);
        points.add(_TracePoint(projected.lat, projected.lng, headingDeg, null));
      }

      final result = await _snapToRoads(key: key, points: points, currentPointIndex: _trace.length - 1);

      _lastFetchLat = lat;
      _lastFetchLng = lng;
      if (result != null) _lastResult = result;
      return result;
    } finally {
      _isRequesting = false;
    }
  }

  void reset() {
    _trace.clear();
    _lastFetchLat = null;
    _lastFetchLng = null;
    _isRequesting = false;
    _lastResult = null;
  }

  // ─── HTTP ─────────────────────────────────────────────────────────────────

  Future<RoadAheadResult?> _snapToRoads({
    required String key,
    required List<_TracePoint> points,
    required int currentPointIndex,
  }) async {
    final uri = _endpoint().replace(queryParameters: {
      'key': key,
      'fields': _fields,
      'vehicleType': 'PassengerCar',
      'measurementSystem': 'metric', // luôn trả kmph / m — không phải quy đổi
      'offroadMargin': '$_offroadMarginM',
    });

    final body = jsonEncode({
      'points': points.map((p) => p.toGeoJson()).toList(),
    });

    try {
      final resp = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        // Log đầy đủ body — bản cũ nuốt lỗi nên tính năng "biến mất" không dấu vết.
        loggerHelper.error(
          '[TOMTOM] HTTP ${resp.statusCode} — ${resp.body}\n'
          'URL: ${uri.replace(queryParameters: {...uri.queryParameters, 'key': '***'})}',
        );
        return null;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return _parse(data, currentPointIndex);
    } catch (e, st) {
      loggerHelper.error('[TOMTOM] Request error: $e', stackTrace: st);
      return null;
    }
  }

  /// Ưu tiên giá trị trong .env, nhưng chỉ khi nó trỏ đúng endpoint snapToRoads.
  /// Nếu .env còn giá trị cũ sai (`/snap-to-roads/1/snap-to-roads`) thì fallback
  /// về endpoint đúng thay vì để tính năng chết im lặng.
  static Uri _endpoint() {
    const fallback = 'https://api.tomtom.com/snapToRoads/1';
    final raw = AppConstants.urlSpeedLimit.trim();
    if (raw.isEmpty || !raw.contains('snapToRoads')) {
      if (raw.isNotEmpty) {
        loggerHelper.error('[TOMTOM] URL_SPEED_LIMIT trong .env sai ("$raw") → dùng $fallback');
      }
      return Uri.parse(fallback);
    }
    return Uri.parse(raw);
  }

  // ─── Parsing ──────────────────────────────────────────────────────────────

  RoadAheadResult? _parse(Map<String, dynamic> data, int currentPointIndex) {
    final route = (data['route'] as List<dynamic>?) ?? const [];
    final projected = (data['projectedPoints'] as List<dynamic>?) ?? const [];
    if (route.isEmpty) return null;

    // projectedPoints giữ đúng thứ tự points đã gửi.
    int? currentRouteIndex;
    if (currentPointIndex < projected.length) {
      final p = projected[currentPointIndex] as Map<String, dynamic>;
      final props = p['properties'] as Map<String, dynamic>? ?? const {};
      final snapResult = props['snapResult'] as String?;
      if (snapResult == 'Matched') {
        currentRouteIndex = (props['routeIndex'] as num?)?.toInt();
      } else {
        loggerHelper.logBlue('[TOMTOM] Điểm hiện tại snapResult=$snapResult');
      }
    }
    currentRouteIndex ??= 0;
    if (currentRouteIndex >= route.length) currentRouteIndex = route.length - 1;

    final currentProps = _propsOf(route[currentRouteIndex]);
    final currentLimit = _speedLimitKmh(currentProps);
    final roadName = (currentProps['address'] as Map<String, dynamic>?)?['roadName'] as String?;

    // ─── Quét các đoạn đường phía trước ───
    SpeedLimitChange? nextLimit;
    final signs = <TrafficSignAhead>[];
    final restrictions = <EmissionRestrictionAhead>[];

    // Khoảng cách cộng dồn tới đầu mỗi road element phía trước.
    // Đoạn hiện tại tính từ vị trí đang đứng nên chỉ là ước lượng.
    double cumulativeM = 0;

    for (var i = currentRouteIndex + 1; i < route.length; i++) {
      final props = _propsOf(route[i]);

      // Biển báo trong đoạn này. chainage = khoảng cách từ đầu đoạn tới biển.
      for (final s in (props['trafficSigns'] as List<dynamic>?) ?? const []) {
        final sign = s as Map<String, dynamic>;
        final signType = sign['signType'] as String?;
        if (signType == null) continue;
        final chainage = _toMeters(
          (sign['chainage'] as num?)?.toDouble() ?? 0,
          sign['unit'] as String?,
        );
        signs.add(TrafficSignAhead(signType: signType, distanceM: cumulativeM + chainage));
      }

      // Hạn chế theo loại xe / phát thải (biển cấm).
      for (final r in (props['emissionRegulations'] as List<dynamic>?) ?? const []) {
        final reg = r as Map<String, dynamic>;
        final type = reg['restrictionType'] as String?;
        if (type == null) continue;
        restrictions.add(EmissionRestrictionAhead(
          restrictionType: type,
          engineTypes: ((reg['engineType'] as List<dynamic>?) ?? const []).map((e) => e.toString()).toList(),
          distanceM: cumulativeM,
        ));
      }

      // Thay đổi giới hạn tốc độ đầu tiên khác với đoạn hiện tại.
      if (nextLimit == null) {
        final limit = _speedLimitKmh(props);
        if (limit > 0 && limit != currentLimit) {
          nextLimit = SpeedLimitChange(valueKmh: limit, distanceM: cumulativeM);
        }
      }

      cumulativeM += _traveledDistanceM(props);
    }

    signs.sort((a, b) => a.distanceM.compareTo(b.distanceM));

    final result = RoadAheadResult(
      currentSpeedLimitKmh: currentLimit,
      roadName: roadName,
      nextSpeedLimit: nextLimit,
      signsAhead: signs,
      restrictionsAhead: restrictions,
    );

    loggerHelper.logBlue('[TOMTOM] $result (route elements=${route.length}, idx=$currentRouteIndex)');
    return result;
  }

  static Map<String, dynamic> _propsOf(dynamic element) =>
      (element as Map<String, dynamic>)['properties'] as Map<String, dynamic>? ?? const {};

  /// `speedLimits: { value, unit, type }` — unit là 'kmph' hoặc 'mph' (CHỮ THƯỜNG).
  /// Chỉ lấy type 'Maximum'; 'Recommended' là tốc độ khuyến nghị, không dùng để
  /// cảnh báo vi phạm.
  static double _speedLimitKmh(Map<String, dynamic> props) {
    final sl = props['speedLimits'] as Map<String, dynamic>?;
    if (sl == null) return 0;

    final type = (sl['type'] as String?) ?? 'Maximum';
    if (type != 'Maximum') return 0;

    final value = (sl['value'] as num?)?.toDouble() ?? 0;
    if (value <= 0) return 0;

    final unit = ((sl['unit'] as String?) ?? 'kmph').toLowerCase();
    return unit == 'mph' ? value * 1.60934 : value;
  }

  static double _traveledDistanceM(Map<String, dynamic> props) {
    final td = props['traveledDistance'] as Map<String, dynamic>?;
    if (td == null) return 0;
    return _toMeters((td['value'] as num?)?.toDouble() ?? 0, td['unit'] as String?);
  }

  /// DistanceUnit của API là `cm`, `m` hoặc `ft`. chainage thường trả về `cm`.
  static double _toMeters(double value, String? unit) {
    switch ((unit ?? 'm').toLowerCase()) {
      case 'cm':
        return value / 100.0;
      case 'ft':
        return value * 0.3048;
      case 'm':
      default:
        return value;
    }
  }

  // ─── Trace buffer ─────────────────────────────────────────────────────────

  void _pushTrace(double lat, double lng, double headingDeg, DateTime ts) {
    if (_trace.isNotEmpty) {
      final last = _trace.last;
      if (_distanceM(last.lat, last.lng, lat, lng) < _minTraceSpacingM) {
        // Cập nhật điểm cuối thay vì thêm mới — giữ vị trí mới nhất mà không
        // làm trace dày đặc các điểm sát nhau.
        _trace[_trace.length - 1] = _TracePoint(lat, lng, headingDeg, ts);
        return;
      }
    }
    _trace.add(_TracePoint(lat, lng, headingDeg, ts));
    while (_trace.length > _maxTracePoints) {
      _trace.removeAt(0);
    }
  }

  // ─── Geo helpers (dùng dart:math chuẩn, KHÔNG xấp xỉ Taylor) ──────────────

  /// Toạ độ điểm cách [lat,lng] [distanceM] mét theo hướng [bearingDeg]
  /// (0 = Bắc, 90 = Đông).
  static _GeoPoint _project(double lat, double lng, double bearingDeg, double distanceM) {
    const r = 6371000.0;
    final bearingRad = bearingDeg * math.pi / 180;
    final latRad = lat * math.pi / 180;
    final lngRad = lng * math.pi / 180;
    final angularDist = distanceM / r;

    final newLatRad = math.asin(
      math.sin(latRad) * math.cos(angularDist) + math.cos(latRad) * math.sin(angularDist) * math.cos(bearingRad),
    );
    final newLngRad = lngRad +
        math.atan2(
          math.sin(bearingRad) * math.sin(angularDist) * math.cos(latRad),
          math.cos(angularDist) - math.sin(latRad) * math.sin(newLatRad),
        );

    return _GeoPoint(newLatRad * 180 / math.pi, newLngRad * 180 / math.pi);
  }

  static double _distanceM(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) * math.sin(dLng / 2) * math.sin(dLng / 2);
    return 2 * r * math.asin(math.min(1.0, math.sqrt(a)));
  }
}

class _TracePoint {
  final double lat;
  final double lng;
  final double headingDeg;
  final DateTime? timestamp;

  const _TracePoint(this.lat, this.lng, this.headingDeg, this.timestamp);

  /// GeoJSON Feature theo đúng request schema của Snap to Roads.
  /// LƯU Ý: coordinates là [longitude, latitude] — KHÔNG phải [lat, lng].
  Map<String, dynamic> toGeoJson() {
    final props = <String, dynamic>{};
    if (!headingDeg.isNaN && headingDeg >= 0) props['heading'] = headingDeg;
    if (timestamp != null) props['timestamp'] = timestamp!.toUtc().toIso8601String();

    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [lng, lat],
      },
      if (props.isNotEmpty) 'properties': props,
    };
  }
}

class _GeoPoint {
  final double lat;
  final double lng;
  const _GeoPoint(this.lat, this.lng);
}
