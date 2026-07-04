import 'package:abhay_app_v2/pages/alert_history/alert_history_controller.dart';
import 'package:get/get.dart';

class AlertHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AlertHistoryController(
        alertHistoryRepository: Get.find(),
      ),
    );
  }
}
