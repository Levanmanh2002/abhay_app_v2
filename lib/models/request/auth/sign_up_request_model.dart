import 'package:json_annotation/json_annotation.dart';

part 'sign_up_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class SignUpRequestModel {
  String fullname;

  @JsonKey(name: 'phone_verified')
  String phone;

  String email;
  String password;

  @JsonKey(name: 'password_confirmation')
  String passwordConfirmation;

  int gender;
  String address;
  String birthday;

  @JsonKey(name: 'max_sound_intensity')
  int? maxSoundIntensity;

  @JsonKey(name: 'max_speed')
  int? maxSpeed;

  SignUpRequestModel({
    required this.fullname,
    required this.phone,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.gender,
    required this.address,
    required this.birthday,
    this.maxSoundIntensity,
    this.maxSpeed,
  });

  factory SignUpRequestModel.fromJson(Map<String, dynamic> json) => _$SignUpRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignUpRequestModelToJson(this);
}
