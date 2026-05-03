import 'package:get/get.dart';

import 'supervised_users_controller.dart';

class SupervisedUsersBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupervisedUsersController());
  }
}
