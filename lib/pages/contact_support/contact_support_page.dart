import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/config/config_info_model.dart';
import 'package:abhay_app_v2/pages/contact_support/contact_support_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/launch_url.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/line_widget.dart';
import 'package:abhay_app_v2/widget/loading_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactSupportPage extends GetWidget<ContactSupportController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(title: 'profile_contact_support'.tr),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingWidget();
          }

          final info = controller.configInfo.value;

          if (info == null) {
            return _buildEmpty();
          }

          final items = _buildItems(info);

          if (items.isEmpty) {
            return _buildEmpty();
          }

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Text(
                  'contact_support_subtitle'.tr,
                  style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                ),
                SizedBox(height: 24.h),
                Container(
                  decoration: BoxDecoration(
                    color: appTheme.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.appColor.withAlpha(15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: items.asMap().entries.map((entry) {
                      final isLast = entry.key == items.length - 1;
                      return _buildContactItem(
                        item: entry.value,
                        isLast: isLast,
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<ContactItem> _buildItems(ConfigInfoModel? info) {
    final items = <ContactItem>[];

    if (info?.hotline?.isNotEmpty == true) {
      items.add(ContactItem(
        icon: Icons.phone_outlined,
        labelKey: 'contact_hotline',
        value: info?.hotline ?? '',
        onTap: () => makePhoneCall(info?.hotline ?? ''),
        color: appTheme.greenColor,
        bgColor: appTheme.bgGreenColor,
      ));
    }

    if (info?.zalo?.isNotEmpty == true) {
      items.add(ContactItem(
        icon: Icons.chat_outlined,
        labelKey: 'contact_zalo',
        value: info?.zalo ?? '',
        onTap: () => onLaunchZaloUrl(info?.zalo ?? ''),
        color: appTheme.blue68FFColor,
        bgColor: appTheme.blue0FFColor,
      ));
    }

    if (info?.facebook?.isNotEmpty == true) {
      items.add(ContactItem(
        icon: Icons.facebook_rounded,
        labelKey: 'contact_facebook',
        value: info?.facebook ?? '',
        onTap: () => openWebPage(info?.facebook ?? ''),
        color: appTheme.blueF2Color,
        bgColor: appTheme.blue0FFColor,
      ));
    }

    if (info?.gmail?.isNotEmpty == true) {
      items.add(ContactItem(
        icon: Icons.email_outlined,
        labelKey: 'contact_gmail',
        value: info?.gmail ?? '',
        onTap: () => launchUrlLink('mailto:${info?.gmail ?? ''}'),
        color: appTheme.errorColor,
        bgColor: appTheme.errorColor.withAlpha(15),
      ));
    }

    return items;
  }

  Widget _buildContactItem({required ContactItem item, required bool isLast}) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          overlayColor: WidgetStateProperty.all(appTheme.transparentColor),
          child: Padding(
            padding: padding(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: item.bgColor,
                  ),
                  child: Icon(item.icon, size: 20.w, color: item.color),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      Text(
                        item.labelKey.tr,
                        style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                      ),
                      Text(
                        item.value,
                        style: StyleThemeData.size14Weight700(),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: appTheme.grayColor),
              ],
            ),
          ),
        ),
        if (!isLast) LineWidget(color: appTheme.grayE6Color),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12.h,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: appTheme.appColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.headset_mic_outlined,
              size: 36.w,
              color: appTheme.appColor,
            ),
          ),
          Text(
            'contact_empty'.tr,
            style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ContactItem {
  final IconData icon;
  final String labelKey;
  final String value;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;

  const ContactItem({
    required this.icon,
    required this.labelKey,
    required this.value,
    required this.onTap,
    required this.color,
    required this.bgColor,
  });
}
