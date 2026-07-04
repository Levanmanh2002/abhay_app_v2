import 'package:latlong2/latlong.dart';

/// Loại cảnh báo giao thông từ TomTom Traffic Incidents API.
enum IncidentCategory {
  unknown(0, 'Unknown', '⚠️'),
  accident(1, 'Accident', '💥'),
  fog(2, 'Fog', '🌫️'),
  dangerousConditions(3, 'Hazard', '⚠️'),
  rain(4, 'Rain', '🌧️'),
  ice(5, 'Ice', '🧊'),
  jam(6, 'Traffic jam', '🚗'),
  laneClosed(7, 'Lane closed', '🚧'),
  roadClosed(8, 'Road closed', '🚫'),
  roadWorks(9, 'Road works', '🔧'),
  wind(10, 'Strong wind', '💨'),
  flooding(11, 'Flooding', '🌊'),
  brokenVehicle(14, 'Broken vehicle', '🔴');

  final int code;
  final String label;
  final String emoji;

  const IncidentCategory(this.code, this.label, this.emoji);

  static IncidentCategory fromCode(int code) {
    return IncidentCategory.values.firstWhere(
      (e) => e.code == code,
      orElse: () => IncidentCategory.unknown,
    );
  }

  /// Mức độ nguy hiểm (dùng để lọc hiển thị)
  bool get isDangerous =>
      this == accident || this == roadClosed || this == dangerousConditions || this == ice || this == flooding;
}

/// Mức độ delay.
enum DelayMagnitude {
  unknown(0),
  minor(1),
  moderate(2),
  major(3);

  final int code;
  const DelayMagnitude(this.code);

  static DelayMagnitude fromCode(int code) {
    return DelayMagnitude.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DelayMagnitude.unknown,
    );
  }
}

class TrafficIncidentModel {
  final String id;
  final LatLng position;
  final IncidentCategory category;
  final DelayMagnitude magnitude;
  final String description;
  final String from;
  final String to;
  final int? delaySeconds;
  final int? lengthMeters;

  const TrafficIncidentModel({
    required this.id,
    required this.position,
    required this.category,
    required this.magnitude,
    required this.description,
    required this.from,
    required this.to,
    this.delaySeconds,
    this.lengthMeters,
  });

  factory TrafficIncidentModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    try {
      final geometry = json['geometry'] as Map<String, dynamic>?;
      final geometryType = geometry?['type'] as String? ?? '';
      final rawCoords = geometry?['coordinates'];

      if (rawCoords != null) {
        switch (geometryType) {
          case 'Point':
            // [lng, lat]
            final c = rawCoords as List<dynamic>;
            if (c.length >= 2) {
              lng = _toDouble(c[0]);
              lat = _toDouble(c[1]);
            }
            break;

          case 'LineString':
          case 'MultiPoint':
            // [[lng,lat], [lng,lat], ...] → lấy điểm giữa
            final c = rawCoords as List<dynamic>;
            if (c.isNotEmpty) {
              final mid = c[c.length ~/ 2];
              if (mid is List && mid.length >= 2) {
                lng = _toDouble(mid[0]);
                lat = _toDouble(mid[1]);
              }
            }
            break;

          case 'MultiLineString':
          case 'Polygon':
            // [[[lng,lat], ...], ...] → lấy điểm đầu của line đầu
            final c = rawCoords as List<dynamic>;
            if (c.isNotEmpty && c[0] is List) {
              final firstLine = c[0] as List<dynamic>;
              if (firstLine.isNotEmpty && firstLine[0] is List) {
                final pt = firstLine[0] as List<dynamic>;
                if (pt.length >= 2) {
                  lng = _toDouble(pt[0]);
                  lat = _toDouble(pt[1]);
                }
              }
            }
            break;
        }
      }
    } catch (_) {}

    final props = (json['properties'] as Map<String, dynamic>?) ?? {};
    final events = (props['events'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final firstEvent = events.isNotEmpty ? events.first : <String, dynamic>{};

    return TrafficIncidentModel(
      id: json['id']?.toString() ?? '${lat}_$lng',
      position: LatLng(lat, lng),
      category: IncidentCategory.fromCode((props['iconCategory'] as num?)?.toInt() ?? 0),
      magnitude: DelayMagnitude.fromCode((props['magnitudeOfDelay'] as num?)?.toInt() ?? 0),
      description: firstEvent['description'] as String? ?? props['from'] as String? ?? 'Road incident',
      from: props['from'] as String? ?? '',
      to: props['to'] as String? ?? '',
      delaySeconds: (props['delay'] as num?)?.toInt(),
      lengthMeters: (props['length'] as num?)?.toInt(),
    );
  }

  /// Parse an item safely to double — handles num, String, etc.
  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static List<TrafficIncidentModel> fromJsonList(List<dynamic> list) =>
      list.map((e) => TrafficIncidentModel.fromJson(e as Map<String, dynamic>)).toList();
}
