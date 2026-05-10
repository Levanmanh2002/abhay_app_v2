import 'package:abhay_app_v2/models/request/auth/sign_up_request_model.dart';
import 'package:abhay_app_v2/models/request/supervised_users/verify_otp_child_request.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:get/get.dart';

class AuthRepository extends IAuthRepository {
  @override
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await clientPostData(AppConstants.loginUri, {
        'identifier': email,
        'password': password,
      });

      if (response.isOk) {
        final String token = response.body['access_token'] ?? '';
        if (token.isNotEmpty) {
          await LocalStorage.setString(SharedKey.token, token);
        }
        DialogUtils.showSuccessDialog('sign_in_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'sign_in_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> signUp(SignUpRequestModel request) async {
    try {
      final response = await clientPostData(AppConstants.signUpUri, request.toJson());

      if (response.isOk) {
        DialogUtils.showSuccessDialog('sign_up_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'sign_up_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> resendOtp(String email) async {
    try {
      final response = await clientPostData(AppConstants.resendOtpUri, {'email': email});

      if (response.isOk) {
        DialogUtils.showSuccessDialog('otp_resend_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'otp_resend_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await clientPostData(AppConstants.verifyOtpUri, {
        'email': email,
        'token_active_account': otp,
      });

      if (response.isOk) {
        DialogUtils.showSuccessDialog('otp_verify_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'otp_verify_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await clientPostData(AppConstants.forgotPasswordUri, {'email': email});

      if (response.isOk) {
        DialogUtils.showSuccessDialog('forgot_password_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'forgot_password_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword(String email, String password) async {
    try {
      final response = await clientPostData(AppConstants.resetPasswordUri, {
        'email': email,
        'password': password,
        'password_confirmation': password,
      });

      if (response.isOk) {
        DialogUtils.showSuccessDialog('reset_password_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'reset_password_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> verifyOTPAddChild(VerifyOtpChildRequest request) async {
    try {
      final response = await clientPostData(AppConstants.verifyOTPAddChildUri, request.toJson());

      if (response.isOk) {
        DialogUtils.showSuccessDialog('otp_verify_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'otp_verify_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }
}
