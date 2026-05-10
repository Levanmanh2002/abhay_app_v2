import 'package:abhay_app_v2/utils/json_utils.dart';
import 'package:json_annotation/json_annotation.dart';

import 'parent_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  int? id;
  String? code;
  String? fullname;
  String? email;

  @JsonKey(name: 'phone_verified')
  String? phoneVerified;

  String? address;
  String? avatar;
  String? birthday;
  int? gender;

  @JsonKey(name: 'max_sound_intensity', fromJson: parseToInt)
  int? maxSound;

  @JsonKey(name: 'max_speed', fromJson: parseToInt)
  int? maxSpeed;

  @JsonKey(name: 'is_stop_alert', fromJson: parseToInt)
  int? isStopAlert;

  @JsonKey(name: 'delay_time_alert', fromJson: parseToInt)
  int? delayTimeAlert;

  @JsonKey(name: 'is_measuring_sound', fromJson: parseToInt)
  int? isMeasuringSound;

  @JsonKey(name: 'is_child_tracking', fromJson: parseToInt)
  int? isChildTracking;

  @JsonKey(name: 'is_auto_detect_speed_limit', fromJson: parseToInt)
  int? isAutoDetectSpeedLimit;

  @JsonKey(fromJson: _parentFromJson)
  ParentModel? parent;

  UserModel({
    this.id,
    this.code,
    this.fullname,
    this.email,
    this.phoneVerified,
    this.address,
    this.avatar,
    this.birthday,
    this.gender,
    this.maxSound,
    this.maxSpeed,
    this.isStopAlert,
    this.delayTimeAlert,
    this.isMeasuringSound,
    this.isChildTracking,
    this.isAutoDetectSpeedLimit,
    this.parent,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static List<UserModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserModel.fromJson(json)).toList();
  }

  UserModel copyWith({
    int? id,
    String? code,
    String? fullname,
    String? email,
    String? phoneVerified,
    String? address,
    String? avatar,
    String? birthday,
    int? gender,
    int? maxSound,
    int? maxSpeed,
    int? isStopAlert,
    int? delayTimeAlert,
    int? isMeasuringSound,
    int? isChildTracking,
    int? isAutoDetectSpeedLimit,
    ParentModel? parent,
  }) {
    return UserModel(
      id: id ?? this.id,
      code: code ?? this.code,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      maxSound: maxSound ?? this.maxSound,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      isStopAlert: isStopAlert ?? this.isStopAlert,
      delayTimeAlert: delayTimeAlert ?? this.delayTimeAlert,
      isMeasuringSound: isMeasuringSound ?? this.isMeasuringSound,
      isChildTracking: isChildTracking ?? this.isChildTracking,
      isAutoDetectSpeedLimit: isAutoDetectSpeedLimit ?? this.isAutoDetectSpeedLimit,
      parent: parent ?? this.parent,
    );
  }

  static ParentModel? _parentFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ParentModel.fromJson(json);
    }
    return null;
  }
}
