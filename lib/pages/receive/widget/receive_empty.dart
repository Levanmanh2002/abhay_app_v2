import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';

class ReceiveEmpty extends StatelessWidget {
  const ReceiveEmpty({super.key, required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12.h,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appTheme.appColor.withAlpha(15),
            ),
            child: Icon(icon, size: 32.w, color: appTheme.appColor),
          ),
          Text(
            message,
            style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
