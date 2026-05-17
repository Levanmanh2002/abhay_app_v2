import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/dashboard/dashboard_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends GetWidget<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteColor,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: controller.animateToTab,
        children: [...controller.pages],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: appTheme.grayE6Color, width: 1.w)),
            color: appTheme.whiteColor,
          ),
          child: AnimatedBottomNavigationBar.builder(
            itemCount: controller.pages.length,
            tabBuilder: (int index, bool isActive) {
              IconData icon;
              String label;
              switch (index) {
                case 0:
                  icon = controller.currentPage.value == 0 ? Icons.directions_car : Icons.directions_car_outlined;
                  label = 'trip_tracking'.tr;
                  break;
                case 1:
                  icon = controller.currentPage.value == 1 ? Icons.people : Icons.people_outline;
                  label = 'recipients'.tr;
                  break;
                case 2:
                  icon = isActive ? Icons.inbox : Icons.inbox_outlined;
                  label = 'tab_received'.tr;
                  break;
                case 3:
                  icon = controller.currentPage.value == 3 ? Icons.notifications : Icons.notifications_none;
                  label = 'alert_received'.tr;
                  break;
                case 4:
                  icon = controller.currentPage.value == 4 ? Icons.person : Icons.person_outline;
                  label = 'profile'.tr;
                  break;
                default:
                  icon = Icons.home;
                  label = '';
              }
              return _buildNavItem(
                icon: icon,
                label: label,
                isActive: isActive,
                hasNotification: index == 2,
              );
            },
            activeIndex: controller.currentPage.value,
            gapLocation: GapLocation.none,
            notchSmoothness: NotchSmoothness.sharpEdge,
            onTap: controller.goToTab,
            notchMargin: 0.1,
            safeAreaValues: const SafeAreaValues(bottom: false),
            height: (12 + 24 + 4 + 12 + 16).h,
            backgroundColor: appTheme.whiteColor,
            borderWidth: 0,
            borderColor: appTheme.transparentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData? icon,
    required String label,
    required bool isActive,
    bool hasNotification = false,
  }) {
    return Padding(
      padding: padding(top: 12),
      child: Column(
        spacing: 4.h,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24.w, color: isActive ? appTheme.appColor : appTheme.oldSliverColor),
          Text(
            label,
            style: isActive
                ? StyleThemeData.size10Weight700(color: appTheme.appColor)
                : StyleThemeData.size10Weight400(color: appTheme.oldSliverColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
