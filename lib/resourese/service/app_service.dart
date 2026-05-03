import 'package:abhay_app_v2/resourese/auth/auth_repository.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/resourese/html/html_repository.dart';
import 'package:abhay_app_v2/resourese/html/ihtml_repository.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/resourese/profile/profile_repository.dart';
import 'package:get/get.dart';

class AppService {
  static Future<void> initAppService() async {
    Get.put<IAuthRepository>(AuthRepository());
    Get.put<IProfileRepository>(ProfileRepository());
    Get.put<IHtmlRepository>(HtmlRepository());
  }
}
