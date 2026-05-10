import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipients_model.g.dart';

@JsonSerializable(includeIfNull: false)
class RecipientsModel {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'user')
  UserModel? user;

  @JsonKey(name: 'receiver_phone')
  String? receiverPhone;

  @JsonKey(name: 'receiver_email')
  String? receiverEmail;

  @JsonKey(name: 'is_sms_notification')
  int? isSmsNotification;

  @JsonKey(name: 'is_email_notification')
  int? isEmailNotification;

  @JsonKey(name: 'is_push_notification')
  int? isPushNotification;

  @JsonKey(name: 'is_approved')
  int? isApproved;

  RecipientsModel({
    this.id,
    this.user,
    this.receiverPhone,
    this.receiverEmail,
    this.isSmsNotification,
    this.isEmailNotification,
    this.isPushNotification,
    this.isApproved,
  });

  factory RecipientsModel.fromJson(Map<String, dynamic> json) => _$RecipientsModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecipientsModelToJson(this);

  static List<RecipientsModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => RecipientsModel.fromJson(json)).toList();
  }
}
