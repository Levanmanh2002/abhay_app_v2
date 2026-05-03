import 'package:json_annotation/json_annotation.dart';

part 'parent_model.g.dart';

@JsonSerializable()
class ParentModel {
  String? fullname;
  String? email;
  String? phone;

  ParentModel({
    this.fullname,
    this.email,
    this.phone,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) => _$ParentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParentModelToJson(this);
}
