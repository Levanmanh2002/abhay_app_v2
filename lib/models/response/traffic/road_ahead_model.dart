/// Kết quả 1 lần gọi TomTom Snap to Roads: thông tin đoạn đường ĐANG đi
/// và các đoạn đường PHÍA TRƯỚC (giới hạn tốc độ sắp thay đổi, biển báo).
///
/// Đặt tại: lib/models/response/traffic/road_ahead_model.dart
library;

class RoadAheadResult {
  /// Giới hạn tốc độ của đoạn đường đang đi (km/h). 0 = không có dữ liệu.
  final double currentSpeedLimitKmh;

  /// Tên đường hiện tại (nếu API trả về).
  final String? roadName;

  /// Thay đổi giới hạn tốc độ gần nhất phía trước. null = không có thay đổi
  /// trong phạm vi đã snap.
  final SpeedLimitChange? nextSpeedLimit;

  /// Danh sách biển báo phía trước, đã sắp xếp theo khoảng cách tăng dần.
  final List<TrafficSignAhead> signsAhead;

  /// Các hạn chế theo loại động cơ / mức phát thải (biển cấm theo loại xe).
  final List<EmissionRestrictionAhead> restrictionsAhead;

  const RoadAheadResult({
    this.currentSpeedLimitKmh = 0,
    this.roadName,
    this.nextSpeedLimit,
    this.signsAhead = const [],
    this.restrictionsAhead = const [],
  });

  bool get isEmpty =>
      currentSpeedLimitKmh <= 0 && nextSpeedLimit == null && signsAhead.isEmpty && restrictionsAhead.isEmpty;

  @override
  String toString() => 'RoadAhead(limit=$currentSpeedLimitKmh, next=$nextSpeedLimit, '
      'signs=${signsAhead.length}, restrictions=${restrictionsAhead.length})';
}

class SpeedLimitChange {
  /// Giới hạn tốc độ mới (km/h).
  final double valueKmh;

  /// Khoảng cách ước tính từ vị trí hiện tại tới điểm bắt đầu đoạn đường mới (mét).
  final double distanceM;

  const SpeedLimitChange({required this.valueKmh, required this.distanceM});

  bool get isIncrease => false; // caller tự so sánh với currentSpeedLimitKmh

  @override
  String toString() => '${valueKmh.toInt()}km/h @${distanceM.toInt()}m';
}

class TrafficSignAhead {
  /// signType thô từ TomTom, ví dụ 'SpeedSign', 'StopSign', 'ChildrenSign'.
  final String signType;

  /// Khoảng cách ước tính tới biển báo (mét).
  final double distanceM;

  const TrafficSignAhead({required this.signType, required this.distanceM});

  /// Nhãn tiếng Việt để hiển thị. Trả về signType thô nếu chưa map.
  String get label => _signLabels[signType] ?? signType;

  /// Biển báo mang tính CẢNH BÁO NGUY HIỂM — nên ưu tiên hiển thị/đọc to.
  bool get isHazard => _hazardSigns.contains(signType);

  @override
  String toString() => '$signType @${distanceM.toInt()}m';
}

class EmissionRestrictionAhead {
  /// 'Ban' = cấm vào, 'Fee' = phải trả phí.
  final String restrictionType;
  final List<String> engineTypes;
  final double distanceM;

  const EmissionRestrictionAhead({
    required this.restrictionType,
    required this.engineTypes,
    required this.distanceM,
  });

  String get label {
    final engines = engineTypes.isEmpty ? '' : ' (${engineTypes.join(', ')})';
    return restrictionType == 'Ban' ? 'Cấm phương tiện$engines' : 'Thu phí phương tiện$engines';
  }
}

// ─── Mapping signType → nhãn tiếng Việt ────────────────────────────────────
// Danh sách signType theo tài liệu Snap to Roads API (RoadElementProperties.trafficSigns).
// Bổ sung thêm khi gặp giá trị mới trong log.
const Map<String, String> _signLabels = {
  'SpeedSign': 'Biển báo giới hạn tốc độ',
  'EndOfSpeedRestrictionSign': 'Hết giới hạn tốc độ',
  'StopSign': 'Biển báo dừng lại',
  'YieldSign': 'Biển báo nhường đường',
  'YieldToOncomingVehiclesSign': 'Nhường đường xe ngược chiều',
  'PriorityRoadSign': 'Đường ưu tiên',
  'EndOfPriorityRoadSign': 'Hết đường ưu tiên',
  'PriorityOverOncomingVehiclesSign': 'Ưu tiên hơn xe ngược chiều',
  'OvertakingRestrictionSign': 'Cấm vượt',
  'EndOfOvertakingRestrictionSign': 'Hết cấm vượt',
  'EndOfAllRestrictionsSign': 'Hết mọi lệnh cấm',
  'PedestrianCrossingSign': 'Vạch qua đường cho người đi bộ',
  'ChildrenSign': 'Khu vực có trẻ em',
  'CyclistsSign': 'Chú ý người đi xe đạp',
  'DangerousCurveSign': 'Khúc cua nguy hiểm',
  'SharpCurveLeftSign': 'Cua gấp sang trái',
  'SharpCurveRightSign': 'Cua gấp sang phải',
  'WindingRoadStartingLeftSign': 'Đường quanh co (trái trước)',
  'WindingRoadStartingRightSign': 'Đường quanh co (phải trước)',
  'SlipperyRoadSign': 'Đường trơn trượt',
  'IcyConditionsSign': 'Đường đóng băng',
  'FogAreaSign': 'Khu vực sương mù',
  'CrossWindSign': 'Gió ngang mạnh',
  'FallingRocksSign': 'Đá rơi',
  'AvalancheAreaSign': 'Khu vực lở tuyết',
  'AccidentHazardSign': 'Khu vực hay xảy ra tai nạn',
  'CongestionHazardSign': 'Khu vực hay ùn tắc',
  'GeneralWarningSign': 'Cảnh báo chung',
  'SteepInclineSign': 'Dốc lên',
  'SteepDeclineSign': 'Dốc xuống',
  'SteepSlopeSign': 'Đường dốc',
  'NarrowingRoadSign': 'Đường hẹp',
  'NarrowingRoadAtLeftSign': 'Hẹp đường bên trái',
  'NarrowingRoadAtRightSign': 'Hẹp đường bên phải',
  'LeftLaneEndsSign': 'Hết làn trái',
  'RightLaneEndsSign': 'Hết làn phải',
  'CenterLaneEndsSign': 'Hết làn giữa',
  'OvertakingLaneSign': 'Làn vượt',
  'RoundaboutAheadSign': 'Sắp tới vòng xuyến',
  'TrafficLightAheadSign': 'Sắp tới đèn tín hiệu',
  'IntersectionWithPriorityToTheRightSign': 'Giao lộ ưu tiên bên phải',
  'GuardedRailwayCrossingSign': 'Đường sắt có rào chắn',
  'UnguardedRailwayCrossingSign': 'Đường sắt không rào chắn',
  'MovableBridgeSign': 'Cầu di động',
  'DomesticAnimalCrossingSign': 'Gia súc qua đường',
  'WildlifeCrossingSign': 'Động vật hoang dã qua đường',
  'BuiltUpAreaEntrySign': 'Vào khu dân cư',
  'BuiltUpAreaExitSign': 'Ra khỏi khu dân cư',
  'VariableTrafficSign': 'Biển báo thay đổi',
};

const Set<String> _hazardSigns = {
  'AccidentHazardSign',
  'DangerousCurveSign',
  'SharpCurveLeftSign',
  'SharpCurveRightSign',
  'SlipperyRoadSign',
  'IcyConditionsSign',
  'FogAreaSign',
  'CrossWindSign',
  'FallingRocksSign',
  'AvalancheAreaSign',
  'ChildrenSign',
  'PedestrianCrossingSign',
  'UnguardedRailwayCrossingSign',
  'GuardedRailwayCrossingSign',
  'SteepDeclineSign',
};
