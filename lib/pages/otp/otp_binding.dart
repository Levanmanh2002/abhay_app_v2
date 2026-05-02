import 'package:get/get.dart';

import 'otp_controller.dart';

class OtpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => OtpController(
        parameter: Get.arguments,
        authRepository: Get.find(),
      ),
    );
  }
}
