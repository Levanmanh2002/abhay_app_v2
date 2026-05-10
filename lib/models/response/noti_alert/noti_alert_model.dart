import 'package:json_annotation/json_annotation.dart';

part 'noti_alert_model.g.dart';

@JsonSerializable(includeIfNull: false)
class NotiAlertModel {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'sender')
  String? sender;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'location')
  String? location;

  @JsonKey(name: 'lat')
  double? lat;

  @JsonKey(name: 'lng')
  double? lng;

  @JsonKey(name: 'speed')
  double? speed;

  @JsonKey(name: 'sound')
  double? sound;

  @JsonKey(name: 'speed_limit')
  int? speedLimit;

  @JsonKey(name: 'status')
  int? status;

  @JsonKey(name: 'type')
  int? type;

  @JsonKey(name: 'created_at')
  String? createdAt;

  NotiAlertModel({
    this.id,
    this.sender,
    this.title,
    this.message,
    this.location,
    this.lat,
    this.lng,
    this.speed,
    this.sound,
    this.speedLimit,
    this.status,
    this.type,
    this.createdAt,
  });

  factory NotiAlertModel.fromJson(Map<String, dynamic> json) => _$NotiAlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotiAlertModelToJson(this);

  NotiAlertModel copyWith({
    int? id,
    String? sender,
    String? title,
    String? message,
    String? location,
    double? lat,
    double? lng,
    double? speed,
    double? sound,
    int? speedLimit,
    int? status,
    int? type,
    String? createdAt,
  }) {
    return NotiAlertModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      title: title ?? this.title,
      message: message ?? this.message,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      speed: speed ?? this.speed,
      sound: sound ?? this.sound,
      speedLimit: speedLimit ?? this.speedLimit,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<NotiAlertModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NotiAlertModel.fromJson(json)).toList();
  }
}
