import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../main.dart';

class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final EdgeInsets? margin;
  final double radius;
  final Widget? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final EdgeInsets? paddingBtn;
  final bool hasSafeArea;
  final bool isFullWidth;
  final TextStyle? styleButtonText;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.margin,
    this.radius = 30,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.paddingBtn,
    this.hasSafeArea = true,
    this.isFullWidth = true,
    this.styleButtonText,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return hasSafeArea ? SafeArea(top: false, child: _buildButtonWidget(context)) : _buildButtonWidget(context);
  }

  Widget _buildButtonWidget(BuildContext context) {
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
          padding: paddingBtn ?? padding(all: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: onPressed == null ? null : gradient,
            color: gradient == null ? (onPressed == null ? appTheme.grayC0Color : color ?? appTheme.appColor) : null,
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
                        valueColor: AlwaysStoppedAnimation<Color>(appTheme.whiteColor),
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text('loading'.tr, style: StyleThemeData.size16Weight700(color: appTheme.whiteColor)),
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
                              color: textColor ?? (onPressed != null ? appTheme.whiteColor : appTheme.whiteColor),
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
