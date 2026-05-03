import 'package:json_annotation/json_annotation.dart';

part 'user_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateUserParams {
  @JsonKey(name: 'fullname')
  String? fullName;

  String? email;

  @JsonKey(name: 'phone_verified')
  String? phone;

  @JsonKey(name: 'max_speed')
  int? maxSpeed;

  @JsonKey(name: 'max_sound_intensity')
  int? maxSound;

  @JsonKey(name: 'is_stop_alert')
  int? isStopAlert;

  @JsonKey(name: 'delay_time_alert')
  int? delayTimeAlert;

  @JsonKey(name: 'is_measuring_sound')
  int? isMeasuringSound;

  @JsonKey(name: 'is_auto_detect_speed_limit')
  int? isAutoDetectSpeedLimit;

  UpdateUserParams({
    this.fullName,
    this.email,
    this.phone,
    this.maxSpeed,
    this.maxSound,
    this.isStopAlert,
    this.delayTimeAlert,
    this.isMeasuringSound,
    this.isAutoDetectSpeedLimit,
  });

  factory UpdateUserParams.fromJson(Map<String, dynamic> json) => _$UpdateUserParamsFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserParamsToJson(this);
}
