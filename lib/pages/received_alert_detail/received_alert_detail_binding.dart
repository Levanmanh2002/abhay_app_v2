import 'package:get/get.dart';

import 'received_alert_detail_controller.dart';

class ReceivedAlertDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReceivedAlertDetailController(parameter: Get.arguments, receiveRepository: Get.find()));
  }
}
