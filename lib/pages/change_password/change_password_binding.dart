import 'package:get/get.dart';

import 'change_password_controller.dart';

class ChangePasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ChangePasswordController(
        parameter: Get.arguments,
        authRepository: Get.find(),
      ),
    );
  }
}
