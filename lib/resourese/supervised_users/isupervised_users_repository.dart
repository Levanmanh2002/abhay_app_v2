import 'package:abhay_app_v2/models/request/supervised_users/supervised_users_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';

import '../ibase_repository.dart';

abstract class ISupervisedUsersRepository extends IBaseRepository {
  Future<bool> sendOTPChild({required String fullName, required String email});
  Future<bool> createSupervisedUsers(SupervisedUsersModel request);
  Future<List<UserModel>> getSupervisedUsers();
}
