import 'package:get/get.dart';

import '_controller.dart';

class TStateBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TStateController());
  }
}
