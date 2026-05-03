import 'package:json_annotation/json_annotation.dart';

part 'config_info_model.g.dart';

@JsonSerializable()
class ConfigInfoModel {
  String? zalo;
  String? facebook;
  String? hotline;
  String? gmail;

  ConfigInfoModel({
    this.zalo,
    this.facebook,
    this.hotline,
    this.gmail,
  });

  factory ConfigInfoModel.fromJson(Map<String, dynamic> json) => _$ConfigInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigInfoModelToJson(this);
}
