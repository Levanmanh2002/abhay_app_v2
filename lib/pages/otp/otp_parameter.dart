import 'package:abhay_app_v2/models/request/supervised_users/supervised_users_model.dart';

enum OtpType { signUp, forgotPassword, supervisedUser }

class OtpParameter {
  final String email;
  final OtpType type;
  final SupervisedUsersModel? supervisedUser;

  OtpParameter({required this.email, required this.type, this.supervisedUser});
}
