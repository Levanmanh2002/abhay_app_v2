import 'package:abhay_app_v2/resourese/auth/auth_repository.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:get/get.dart';

class AppService {
  static Future<void> initAppService() async {
    Get.put<IAuthRepository>(AuthRepository());
  }
}
