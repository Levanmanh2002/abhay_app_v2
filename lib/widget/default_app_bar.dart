import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/image_asset_custom.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool backButton;
  final Function? onBackPressed;
  final String? type;
  final bool centerTitle;
  final List<Widget> actions;
  final Widget? backIcon;
  final Color? backgroundColor;
  final Widget? widgetText;
  final Color? colorTitle;
  final Color? colorIcon;
  final bool isBackIconCustom;

  const DefaultAppBar({
    super.key,
    this.title = '',
    this.titleStyle,
    this.backButton = true,
    this.onBackPressed,
    this.type,
    this.centerTitle = true,
    this.actions = const [],
    this.backIcon,
    this.backgroundColor,
    this.widgetText,
    this.colorTitle,
    this.colorIcon,
    this.isBackIconCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? appTheme.whiteColor,
      surfaceTintColor: appTheme.whiteColor,
      title: widgetText ??
          Text(
            title,
            style: titleStyle ?? StyleThemeData.size16Weight700(color: colorTitle),
          ),
      centerTitle: centerTitle,
      leading: backButton
          ? isBackIconCustom
              ? Padding(
                  padding: padding(left: 8),
                  child: Center(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: appTheme.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: appTheme.appColor.withAlpha(15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16.w,
                          color: appTheme.blackColor,
                        ),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () => onBackPressed != null ? onBackPressed!() : Get.back(),
                  icon: backIcon ?? ImageAssetCustom(imagePath: Assets.icons.arrowLeft.path, color: colorIcon),
                )
          : const SizedBox(),
      leadingWidth: backButton
          ? isBackIconCustom
              ? 72.w
              : null
          : 0,
      elevation: 0,
      actions: actions,
      titleSpacing: centerTitle ? null : 0,
    );
  }

  @override
  Size get preferredSize => Size(Get.width, 50);
}
