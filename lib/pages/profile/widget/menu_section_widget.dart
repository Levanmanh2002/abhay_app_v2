import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/line_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuItem {
  final IconData icon;
  final String labelKey;
  final VoidCallback onTap;
  final bool isDestructive;

  const MenuItem({
    required this.icon,
    required this.labelKey,
    required this.onTap,
    this.isDestructive = false,
  });
}

class MenuSectionWidget extends StatelessWidget {
  const MenuSectionWidget({super.key, required this.items});

  final List<MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appTheme.appColor.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          return _buildMenuItem(item: item, isLast: isLast, index: index);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({required MenuItem item, required bool isLast, required int index}) {
    final color = item.isDestructive ? appTheme.errorColor : appTheme.blackColor;
    final iconBgColor = item.isDestructive ? appTheme.errorColor.withAlpha(15) : appTheme.appColor.withAlpha(15);
    final iconColor = item.isDestructive ? appTheme.errorColor : appTheme.appColor;

    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          child: Padding(
            padding: padding(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18.w, color: iconColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    item.labelKey.tr,
                    style: StyleThemeData.size14Weight400(color: color),
                  ),
                ),
                if (!item.isDestructive) Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: appTheme.grayColor),
              ],
            ),
          ),
        ),
        if (!isLast) LineWidget(color: appTheme.grayE6Color),
      ],
    );
  }
}
