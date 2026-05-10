import 'package:abhay_app_v2/resourese/auth/auth_repository.dart';
import 'package:abhay_app_v2/resourese/auth/iauth_repository.dart';
import 'package:abhay_app_v2/resourese/html/html_repository.dart';
import 'package:abhay_app_v2/resourese/html/ihtml_repository.dart';
import 'package:abhay_app_v2/resourese/noti/inoti_repository.dart';
import 'package:abhay_app_v2/resourese/noti/noti_repository.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/resourese/profile/profile_repository.dart';
import 'package:abhay_app_v2/resourese/recipients/irecipients_repository.dart';
import 'package:abhay_app_v2/resourese/recipients/recipients_repository.dart';
import 'package:abhay_app_v2/resourese/supervised_users/isupervised_users_repository.dart';
import 'package:abhay_app_v2/resourese/supervised_users/supervised_users_repository.dart';
import 'package:get/get.dart';

class AppService {
  static Future<void> initAppService() async {
    Get.put<IAuthRepository>(AuthRepository());
    Get.put<IProfileRepository>(ProfileRepository());
    Get.put<IHtmlRepository>(HtmlRepository());
    Get.put<ISupervisedUsersRepository>(SupervisedUsersRepository());
    Get.put<IRecipientsRepository>(RecipientsRepository());
    Get.put<INotiRepository>(NotiRepository());
  }
}
