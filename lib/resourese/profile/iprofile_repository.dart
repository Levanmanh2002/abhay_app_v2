import 'package:abhay_app_v2/models/request/profile/user_request_model.dart';
import 'package:abhay_app_v2/models/response/config/config_info_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';

import '../ibase_repository.dart';

abstract class IProfileRepository extends IBaseRepository {
  Future<UserModel?> getProfile();
  Future<UserModel?> updateProfile(UpdateUserParams params, List<MultipartBody> multipartBody);
  Future<ConfigInfoModel?> getConfigInfo();
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  });
  Future<bool> logout();
  Future<void> updateFcmToken(String fcmToken);
}
