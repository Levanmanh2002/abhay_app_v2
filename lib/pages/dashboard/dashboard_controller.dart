import 'package:abhay_app_v2/pages/home/home_page.dart';
import 'package:abhay_app_v2/pages/noti/noti_page.dart';
import 'package:abhay_app_v2/pages/profile/profile_page.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  late PageController pageController;
  RxInt currentPage = 0.obs;

  List<Widget> pages = [
    HomePage(),
    RecipientsPage(),
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

  Future<void> init() async {}
}
