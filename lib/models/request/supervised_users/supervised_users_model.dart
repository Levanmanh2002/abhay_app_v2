import 'package:json_annotation/json_annotation.dart';

part 'supervised_users_model.g.dart';

@JsonSerializable(includeIfNull: false)
class SupervisedUsersModel {

  @JsonKey(name: 'fullname')
  String fullname;

  String email;
  String phone;
  String password;

  @JsonKey(name: 'passwordConfirm')
  String passwordConfirm;

  SupervisedUsersModel({
    required this.fullname,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirm,
  });

  factory SupervisedUsersModel.fromJson(Map<String, dynamic> json) => _$SupervisedUsersModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupervisedUsersModelToJson(this);
}
