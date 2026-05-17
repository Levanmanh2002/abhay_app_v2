import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/dialogs/create_recipients_view.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipientEmpty extends StatelessWidget {
  const RecipientEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.h,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: appTheme.appColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline_rounded, size: 36.w, color: appTheme.appColor),
          ),
          Text(
            'recipients_empty'.tr,
            style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
            textAlign: TextAlign.center,
          ),
          InkWell(
            onTap: () => CreateRecipientsView.show(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: padding(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: appTheme.appColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6.w,
                children: [
                  Icon(Icons.add_rounded, color: appTheme.whiteColor, size: 18.w),
                  Text('recipient_add'.tr, style: StyleThemeData.size14Weight700(color: appTheme.whiteColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
