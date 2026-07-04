import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:abhay_app_v2/models/response/traffic/traffic_incident_model.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoadWarning {
  final String id;
  final RoadWarningType type;
  final String message;
  final String detail;
  final double distanceM;
  final LatLng? position;

  const RoadWarning({
    required this.id,
    required this.type,
    required this.message,
    required this.detail,
    required this.distanceM,
    this.position,
  });
}

enum RoadWarningType {
  speedLimitExceeded,
  incident,
  hazard,
  roadWork,
  trafficJam,
}

class RoadWarningService {
  static const double warningRadiusM = 400.0;
  static const double _refetchDistM = 300.0;
  static const int _speedGracePct = 10;

  String _apiKey = '';
  double? _lastFetchLat;
  double? _lastFetchLng;
  bool _isFetching = false;

  final List<TrafficIncidentModel> _incidents = [];
  List<TrafficIncidentModel> get incidents => List.unmodifiable(_incidents);

  final List<RoadWarning> _activeWarnings = [];
  List<RoadWarning> get activeWarnings => List.unmodifiable(_activeWarnings);

  bool get isOverTomtomLimit => _activeWarnings.any((w) => w.type == RoadWarningType.speedLimitExceeded);

  void init(String apiKey) {
    _apiKey = apiKey.trim();
  }

  void reset() {
    _incidents.clear();
    _activeWarnings.clear();
    _lastFetchLat = null;
    _lastFetchLng = null;
  }

  Future<void> update({
    required double lat,
    required double lng,
    required double speedKmh,
    required double tomtomLimit,
  }) async {
    final shouldFetch = _lastFetchLat == null || _distanceM(_lastFetchLat!, _lastFetchLng!, lat, lng) >= _refetchDistM;

    if (shouldFetch && _apiKey.isNotEmpty) {
      await _fetchIncidents(lat, lng);
    }

    _recalcWarnings(
      lat: lat,
      lng: lng,
      speedKmh: speedKmh,
      tomtomLimit: tomtomLimit,
    );
  }

  Future<void> _fetchIncidents(double lat, double lng) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      const radiusKm = 5.0;
      final d = radiusKm / 111.0;
      final bboxStr = '${(lng - d).toStringAsFixed(6)},${(lat - d).toStringAsFixed(6)}'
          ',${(lng + d).toStringAsFixed(6)},${(lat + d).toStringAsFixed(6)}';

      final uri = Uri(
        scheme: 'https',
        host: 'api.tomtom.com',
        path: '/traffic/services/5/incidentDetails',
        queryParameters: {
          'key': _apiKey,
          'bbox': bboxStr,
          'language': 'en-GB',
          'timeValidityFilter': 'present',
        },
      );

      loggerHelper.logBlue('[TRAFFIC] Fetching: $uri');

      final resp = await http.get(uri).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final list = data['incidents'] as List<dynamic>? ?? [];

        // fromJsonList đã handle tất cả geometry types an toàn
        _incidents
          ..clear()
          ..addAll(TrafficIncidentModel.fromJsonList(list));

        _lastFetchLat = lat;
        _lastFetchLng = lng;
        loggerHelper.logBlue('[TRAFFIC] Found ${_incidents.length} incidents (${radiusKm}km)');
      } else {
        loggerHelper.error('[TRAFFIC] HTTP ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      loggerHelper.error('[TRAFFIC] Error: $e');
    } finally {
      _isFetching = false;
    }
  }

  void _recalcWarnings({
    required double lat,
    required double lng,
    required double speedKmh,
    required double tomtomLimit,
  }) {
    _activeWarnings.clear();

    // 1. Vượt speed limit TomTom
    if (tomtomLimit > 0 && speedKmh > 5) {
      final allowed = tomtomLimit * (1 + _speedGracePct / 100);
      if (speedKmh > allowed) {
        _activeWarnings.add(RoadWarning(
          id: 'speed_limit',
          type: RoadWarningType.speedLimitExceeded,
          message: 'Vượt giới hạn tốc độ',
          detail: '${speedKmh.toInt()} / ${tomtomLimit.toInt()} km/h',
          distanceM: 0,
        ));
      }
    }

    // 2. Incidents trong bán kính
    for (final incident in _incidents) {
      final dist = _distanceM(
        lat,
        lng,
        incident.position.latitude,
        incident.position.longitude,
      );
      if (dist <= warningRadiusM) {
        _activeWarnings.add(RoadWarning(
          id: incident.id,
          type: _typeFromCategory(incident.category),
          message: '${incident.category.emoji} ${incident.category.label}',
          detail: incident.description.isNotEmpty ? incident.description : _formatDelay(incident.delaySeconds),
          distanceM: dist,
          position: incident.position,
        ));
      }
    }

    _activeWarnings.sort((a, b) {
      final diff = _priority(b.type).compareTo(_priority(a.type));
      return diff != 0 ? diff : a.distanceM.compareTo(b.distanceM);
    });
  }

  RoadWarningType _typeFromCategory(IncidentCategory cat) {
    switch (cat) {
      case IncidentCategory.accident:
        return RoadWarningType.incident;
      case IncidentCategory.dangerousConditions:
      case IncidentCategory.fog:
      case IncidentCategory.ice:
      case IncidentCategory.rain:
      case IncidentCategory.wind:
      case IncidentCategory.flooding:
        return RoadWarningType.hazard;
      case IncidentCategory.roadWorks:
      case IncidentCategory.laneClosed:
      case IncidentCategory.roadClosed:
        return RoadWarningType.roadWork;
      case IncidentCategory.jam:
        return RoadWarningType.trafficJam;
      default:
        return RoadWarningType.incident;
    }
  }

  int _priority(RoadWarningType type) {
    switch (type) {
      case RoadWarningType.speedLimitExceeded:
        return 5;
      case RoadWarningType.incident:
        return 4;
      case RoadWarningType.hazard:
        return 3;
      case RoadWarningType.roadWork:
        return 2;
      case RoadWarningType.trafficJam:
        return 1;
    }
  }

  String _formatDelay(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    return seconds < 60 ? '${seconds}s delay' : '${(seconds / 60).round()} min delay';
  }

  static double _distanceM(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * asin(sqrt(a));
  }
}
