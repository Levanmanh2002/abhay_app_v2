import 'package:get/get.dart';

import 'update_password_controller.dart';

class UpdatePasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => UpdatePasswordController(
        profileRepository: Get.find(),
      ),
    );
  }
}
