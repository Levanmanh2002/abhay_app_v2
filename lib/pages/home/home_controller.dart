import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxDouble speed = 0.0.obs;
  final RxDouble sound = 0.0.obs;
  final RxDouble maxSpeed = 60.0.obs;
  final RxBool isTracking = false.obs;
  final RxBool isAutoDetect = false.obs;
  final RxString location = ''.obs;
}
