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
import 'package:abhay_app_v2/resourese/service/tracking/tracking_service.dart';
import 'package:abhay_app_v2/resourese/supervised_users/isupervised_users_repository.dart';
import 'package:abhay_app_v2/resourese/supervised_users/supervised_users_repository.dart';
import 'package:abhay_app_v2/resourese/tracking/itracking_repository.dart';
import 'package:abhay_app_v2/resourese/tracking/tracking_repository.dart';
import 'package:get/get.dart';

class AppService {
  static Future<void> initAppService() async {
    // Repositories
    Get.put<IAuthRepository>(AuthRepository());
    Get.put<IProfileRepository>(ProfileRepository());
    Get.put<IHtmlRepository>(HtmlRepository());
    Get.put<ISupervisedUsersRepository>(SupervisedUsersRepository());
    Get.put<IRecipientsRepository>(RecipientsRepository());
    Get.put<INotiRepository>(NotiRepository());
    Get.put<ITrackingRepository>(TrackingRepository());

    // Services (permanent = survive route changes)
    Get.put<TrackingService>(TrackingService(), permanent: true);
  }
}
