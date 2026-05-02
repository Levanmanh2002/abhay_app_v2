import 'package:get/get.dart';

import 'forgot_password_controller.dart';

class ForgotPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ForgotPasswordController(
        authRepository: Get.find(),
      ),
    );
  }
}
