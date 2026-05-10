import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_child_request.g.dart';

@JsonSerializable(includeIfNull: false)
class VerifyOtpChildRequest {
  @JsonKey(name: 'fullname')
  String? fullname;

  @JsonKey(name: 'phone_verified')
  String? phoneVerified;

  @JsonKey(name: 'email')
  String? email;

  @JsonKey(name: 'password')
  String? password;

  @JsonKey(name: 'password_confirmation')
  String? passwordConfirmation;

  @JsonKey(name: 'gender')
  String? gender;

  @JsonKey(name: 'active')
  String? active;

  @JsonKey(name: 'max_sound_intensity')
  String? maxSound;

  @JsonKey(name: 'max_speed')
  String? maxSpeed;

  @JsonKey(name: 'is_stop_alert')
  String? isStopAlert;

  @JsonKey(name: 'delay_time_alert')
  String? delayTimeAlert;

  @JsonKey(name: 'otp')
  String? otp;

  VerifyOtpChildRequest({
    this.fullname,
    this.phoneVerified,
    this.email,
    this.password,
    this.passwordConfirmation,
    this.gender,
    this.active,
    this.maxSound,
    this.maxSpeed,
    this.isStopAlert,
    this.delayTimeAlert,
    this.otp,
  });

  factory VerifyOtpChildRequest.fromJson(Map<String, dynamic> json) => _$VerifyOtpChildRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpChildRequestToJson(this);
}
