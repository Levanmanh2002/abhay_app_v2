import 'package:abhay_app_v2/pages/home/home_page.dart';
import 'package:abhay_app_v2/pages/noti/noti_controller.dart';
import 'package:abhay_app_v2/pages/noti/noti_page.dart';
import 'package:abhay_app_v2/pages/profile/profile_page.dart';
import 'package:abhay_app_v2/pages/receive/receive_controller.dart';
import 'package:abhay_app_v2/pages/receive/receive_page.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_controller.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_page.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/resourese/service/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final NotificationService notificationService;
  final IProfileRepository profileRepository;

  DashboardController({required this.notificationService, required this.profileRepository});

  late PageController pageController;
  RxInt currentPage = 0.obs;

  List<Widget> pages = [
    HomePage(),
    RecipientsPage(),
    ReceivePage(),
    NotiPage(),
    ProfilePage(),
  ];

  @override
  void onInit() {
    pageController = PageController(initialPage: 0);
    init();
    super.onInit();
  }

  void goToTab(int page) {
    if (page == 1) {
      Get.find<RecipientsController>().onRefresh();
    } else if (page == 2) {
      Get.find<ReceiveController>().onRefresh();
    } else if (page == 3) {
      Get.find<NotiController>().onRefresh();
    }
    currentPage.value = page;
    pageController.jumpToPage(page);
  }

  void animateToTab(int page) {
    currentPage.value = page;
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Future<void> init() async {
    await notificationService.onInit();
    await notificationService.onRequestPermission();

    final fcmToken = await notificationService.getFcmToken();
    if (fcmToken != null) await profileRepository.updateFcmToken(fcmToken);
    await notificationService.onHandleInitialMessage();
  }
}
