import 'package:get/get.dart';

import 'my_info_controller.dart';

class MyInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MyInfoController(
        parameter: Get.arguments,
        profileRepository: Get.find(),
        profileController: Get.find(),
      ),
    );
  }
}
