import 'package:abhay_app_v2/models/request/auth/sign_up_request_model.dart';
import 'package:abhay_app_v2/resourese/ibase_repository.dart';

abstract class IAuthRepository extends IBaseRepository {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(SignUpRequestModel request);
  Future<bool> resendOtp(String email);
  Future<bool> verifyOtp(String email, String otp);
  Future<bool> forgotPassword(String email);
  Future<bool> resetPassword(String email, String password);
}
