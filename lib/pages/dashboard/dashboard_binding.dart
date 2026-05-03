import 'package:abhay_app_v2/pages/dashboard/dashboard_controller.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:get/get.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    Get.put(HomeController());
    Get.put(ProfileController(profileRepository: Get.find()));
  }
}
