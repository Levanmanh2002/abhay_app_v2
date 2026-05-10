import 'package:abhay_app_v2/models/request/supervised_users/supervised_users_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:get/get.dart';

import 'isupervised_users_repository.dart';

class SupervisedUsersRepository extends ISupervisedUsersRepository {
  @override
  Future<bool> sendOTPChild({required String fullName, required String email}) async {
    try {
      final response = await clientPostData(AppConstants.sendOTPChildUri, {
        'fullname': fullName,
        'email': email,
      });

      if (response.isOk) {
        DialogUtils.showSuccessDialog('otp_sent_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'otp_sent_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> createSupervisedUsers(SupervisedUsersModel request) async {
    try {
      final response = await clientPostData(AppConstants.createSupervisedUsersUri, request.toJson());

      if (response.isOk) {
        DialogUtils.showSuccessDialog('supervised_user_creation_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'supervised_user_creation_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<List<UserModel>> getSupervisedUsers() async {
    try {
      final response = await clientGetData(AppConstants.getSupervisedUsersUri);

      if (response.isOk) {
        final List<dynamic> data = response.body['data'] ?? [];
        final List<UserModel> users = UserModel.fromJsonList(data);
        return users;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'failed_to_load_supervised_users'.tr);
        return [];
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }
}
