import 'package:latlong2/latlong.dart';

enum RoadSignType {
  speedLimit, // biển giới hạn tốc độ
  speedBump, // gờ giảm tốc
  trafficSignal, // đèn tín hiệu
  stopSign, // biển dừng
  giveWay, // nhường đường
  crossing, // vạch sang đường
  schoolZone, // khu vực trường học
  hospitalZone, // khu vực bệnh viện
  noEntry, // cấm vào
  oneWay, // đường một chiều
  sharpCurve, // khúc cua nguy hiểm
  narrowRoad, // đường hẹp
  roadWork, // công trình
  unknown,
}

class RoadSignModel {
  final String id;
  final LatLng position;
  final RoadSignType type;
  final String label;
  final String? value; // VD: "60" cho speed limit, "left" cho one way
  final double distanceM;

  const RoadSignModel({
    required this.id,
    required this.position,
    required this.type,
    required this.label,
    this.value,
    required this.distanceM,
  });

  String get emoji {
    switch (type) {
      case RoadSignType.speedLimit:
        return '🔴';
      case RoadSignType.speedBump:
        return '🔶';
      case RoadSignType.trafficSignal:
        return '🚦';
      case RoadSignType.stopSign:
        return '🛑';
      case RoadSignType.giveWay:
        return '⚠️';
      case RoadSignType.crossing:
        return '🚶';
      case RoadSignType.schoolZone:
        return '🏫';
      case RoadSignType.hospitalZone:
        return '🏥';
      case RoadSignType.noEntry:
        return '⛔';
      case RoadSignType.oneWay:
        return '↗️';
      case RoadSignType.sharpCurve:
        return '🔄';
      case RoadSignType.narrowRoad:
        return '↔️';
      case RoadSignType.roadWork:
        return '🚧';
      case RoadSignType.unknown:
        return '⚠️';
    }
  }

  String get displayLabel {
    if (value != null && value!.isNotEmpty) return '$label: $value';
    return label;
  }
}
