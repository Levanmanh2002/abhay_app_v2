import 'package:abhay_app_v2/pages/dashboard/dashboard_controller.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/pages/noti/noti_controller.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_controller.dart';
import 'package:get/get.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    // HomeController phụ thuộc vào TrackingService (đã được put permanent trong AppService)
    Get.put(HomeController());
    Get.put(ProfileController(profileRepository: Get.find()));
    Get.put(RecipientsController(recipientsRepository: Get.find()));
    Get.put(NotiController(notiRepository: Get.find()));
    Get.put(DashboardController());
  }
}
