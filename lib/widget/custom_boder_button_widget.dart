import 'package:abhay_app_v2/core/app_border_shadow.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';

class CustomBorderButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final EdgeInsets? margin;
  final double radius;
  final Widget? icon;
  final Color? color;
  final Color? textColor;
  final Color? backgroundColor;
  final bool isLoading;
  final TextStyle? styleButtonText;
  final EdgeInsets? paddingBtn;
  final bool hasSafeArea;
  final bool isFullWidth;
  final bool isBoxShadow;

  const CustomBorderButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.margin,
    this.radius = 30,
    this.icon,
    this.color,
    this.textColor,
    this.backgroundColor,
    this.isLoading = false,
    this.styleButtonText,
    this.paddingBtn,
    this.hasSafeArea = true,
    this.isFullWidth = true,
    this.isBoxShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return hasSafeArea
        ? SafeArea(top: false, child: _buildBorderButtonWidget(context))
        : _buildBorderButtonWidget(context);
  }

  Widget _buildBorderButtonWidget(BuildContext context) {
    return Padding(
      padding: margin == null ? EdgeInsets.zero : margin!,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                FocusScope.of(context).unfocus();
                onPressed?.call();
              },
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          padding: paddingBtn ?? padding(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              width: 1.w,
              color: onPressed == null ? appTheme.grayC0Color : color ?? appTheme.appColor,
            ),
            color: backgroundColor ?? appTheme.whiteColor,
            boxShadow: isBoxShadow ? AppBorderShadow.boxShadow : null,
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 15.w,
                      width: 15.w,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(textColor ?? appTheme.appColor),
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text('loading'.tr, style: StyleThemeData.size16Weight700(color: textColor ?? appTheme.appColor)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    icon != null ? Padding(padding: padding(right: 8), child: icon) : const SizedBox(),
                    Flexible(
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        style: styleButtonText ??
                            StyleThemeData.size16Weight700(
                              color: (onPressed != null ? textColor : appTheme.gray86Color) ??
                                  (onPressed != null ? appTheme.appColor : appTheme.gray86Color),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
