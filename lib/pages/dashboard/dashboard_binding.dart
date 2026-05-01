import 'package:abhay_app_v2/pages/dashboard/dashboard_controller.dart';
import 'package:get/get.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    // if (Platform.isWindows) {
    //   Get.put(NotificationServiceWindows());
    // } else {
    //   Get.put(NotificationService());
    // }
    Get.put(DashboardController());
  }
}
