import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/receive/receive_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabBarReceiveView extends GetView<ReceiveController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding(horizontal: 16, vertical: 12),
      padding: padding(all: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: appTheme.grayE6Color,
      ),
      child: Row(
        children: [
          _tabButton(0, 'receive_tab_alerts'.tr, Icons.notifications_outlined),
          _tabButton(1, 'receive_tab_requests'.tr, Icons.person_add_outlined),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String label, IconData icon) {
    return Obx(() {
      final isActive = controller.currentTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: () => controller.currentTab.value = index,
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: padding(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? appTheme.whiteColor : appTheme.transparentColor,
              borderRadius: BorderRadius.circular(9),
              boxShadow: isActive ? [BoxShadow(color: appTheme.black00Color.withAlpha(10), blurRadius: 4)] : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6.w,
              children: [
                Icon(
                  icon,
                  size: 16.w,
                  color: isActive ? appTheme.appColor : appTheme.grayColor,
                ),
                Text(
                  label,
                  style: isActive
                      ? StyleThemeData.size12Weight700(color: appTheme.appColor)
                      : StyleThemeData.size12Weight400(color: appTheme.grayColor),
                ),
                if (index == 1)
                  Obx(() {
                    final count = controller.requests.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: padding(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: appTheme.errorColor,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '$count',
                        style: StyleThemeData.size10Weight700(color: appTheme.whiteColor),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      );
    });
  }
}
