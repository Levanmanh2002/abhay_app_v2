import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';

class AppCheckBox extends StatelessWidget {
  final bool isChecked;
  final double size;
  final double iconSize;
  final VoidCallback? onChecked;
  final bool isCircle;
  final Color? colorBorderEmpty;
  final Color? color;
  final Color? colorIcon;

  const AppCheckBox({
    required this.isChecked,
    this.size = 20,
    this.iconSize = 12,
    this.onChecked,
    this.isCircle = false,
    this.colorBorderEmpty,
    this.color,
    this.colorIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChecked,
      borderRadius: isCircle == true ? null : BorderRadius.circular(4),
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          borderRadius: isCircle == true ? null : BorderRadius.circular(4),
          shape: isCircle == true ? BoxShape.circle : BoxShape.rectangle,
          border: Border.all(color: isChecked ? appTheme.appColor : colorBorderEmpty ?? appTheme.blackColor),
          color: isChecked ? color ?? appTheme.appColor : appTheme.whiteColor,
        ),
        child: Center(
          child: Icon(
            Icons.check,
            size: iconSize,
            color: isChecked ? colorIcon ?? appTheme.whiteColor : appTheme.transparentColor,
          ),
        ),
      ),
    );
  }
}
