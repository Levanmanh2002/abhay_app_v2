import 'package:get/get.dart';

import 'receive_controller.dart';

class ReceiveBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ReceiveController(
        repository: Get.find(),
      ),
    );
  }
}
