import 'package:json_annotation/json_annotation.dart';

part 'receiver_model.g.dart';

@JsonSerializable(includeIfNull: false)
class ReceiverModel {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'sender_avatar')
  String? senderAvatar;

  @JsonKey(name: 'sender_name')
  String? senderName;

  @JsonKey(name: 'sender_email')
  String? senderEmail;

  @JsonKey(name: 'sender_phone')
  String? senderPhone;

  @JsonKey(name: 'status')
  int? status;

  @JsonKey(name: 'created_at')
  String? createdAt;

  ReceiverModel({
    this.id,
    this.senderAvatar,
    this.senderName,
    this.senderEmail,
    this.senderPhone,
    this.status,
    this.createdAt,
  });

  factory ReceiverModel.fromJson(Map<String, dynamic> json) => _$ReceiverModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiverModelToJson(this);

  static List<ReceiverModel> fromJsonList(List<dynamic> list) => list.map((e) => ReceiverModel.fromJson(e)).toList();
}
