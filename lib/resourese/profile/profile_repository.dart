import 'package:abhay_app_v2/models/request/profile/user_request_model.dart';
import 'package:abhay_app_v2/models/response/config/config_info_model.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/resourese/ibase_repository.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:get/get.dart';

import 'iprofile_repository.dart';

class ProfileRepository extends IProfileRepository {
  @override
  Future<UserModel?> getProfile() async {
    try {
      final response = await clientGetData(AppConstants.profileUri);

      if (response.isOk) {
        return UserModel.fromJson(response.body['data']);
      } else {
        return null;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<UserModel?> updateProfile(UpdateUserParams params, List<MultipartBody> multipartBody) async {
    try {
      final response = await clientPostMultipartData(
        AppConstants.updateProfileUri,
        params.toJson().map((key, value) => MapEntry(key, value.toString())),
        multipartBody,
      );

      if (response.isOk) {
        DialogUtils.showSuccessDialog('update_profile_success'.tr);
        return UserModel.fromJson(response.body['data']);
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'update_profile_failed'.tr);
        return null;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<ConfigInfoModel?> getConfigInfo() async {
    try {
      final response = await clientGetData(AppConstants.configInfoUri);

      if (response.isOk) {
        return ConfigInfoModel.fromJson(response.body['data']);
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'fetch_config_info_failed'.tr);
        return null;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final response = await clientPostData(
        AppConstants.changePasswordUri,
        {
          'old_password': oldPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirm,
        },
      );

      if (response.isOk) {
        DialogUtils.showSuccessDialog('change_password_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'change_password_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await clientPostData(AppConstants.logoutUri, {});

      if (response.isOk) {
        DialogUtils.showSuccessDialog('logout_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'logout_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await clientPostData(AppConstants.updateFcmTokenUri, {'device_token': fcmToken});
    } catch (error) {
      handleError(error);
    }
  }
}
