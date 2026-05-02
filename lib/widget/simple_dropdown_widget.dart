import 'package:abhay_app_v2/extension/color_extension.dart';
import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SimpleDropdownWidget<T> extends StatelessWidget {
  const SimpleDropdownWidget({
    super.key,
    required this.items,
    this.selectedItem,
    required this.itemAsString,
    this.title = '',
    this.hintText,
    this.errorText = '',
    this.onChanged,
    this.enabled = true,
    this.suffixIcon,
    this.isExpanded = true,
    this.prefixIcon,
    this.paddingCustom,
    this.radiusBorder = 8,
    this.styleTitle,
    this.isRequired = false,
    this.isFullExpanded = false,
    this.backgroundColor,
    this.borderColor,
    this.styleSelected,
    this.isLoading = false,
    this.canOpen = true,
    this.iconTitle,
  });

  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemAsString;
  final String title;
  final String? hintText;
  final String errorText;
  final Function(T?)? onChanged;
  final bool enabled;
  final Widget? suffixIcon;
  final bool isExpanded;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? paddingCustom;
  final double radiusBorder;
  final TextStyle? styleTitle;
  final bool isRequired;
  final bool isFullExpanded;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? styleSelected;
  final bool isLoading;
  final bool canOpen;
  final Widget? iconTitle;

  @override
  Widget build(BuildContext context) {
    final isDropdownOpen = false.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty) ...[
          Row(
            spacing: 4.w,
            children: [
              if (iconTitle != null) ...[iconTitle!],
              Text(title, style: styleTitle ?? StyleThemeData.size14Weight700()),
              if (isRequired) ...[
                Text('*', style: StyleThemeData.size14Weight700(color: appTheme.errorColor)),
              ],
            ],
          ),
          SizedBox(height: 8.h),
        ],
        isFullExpanded
            ? Expanded(child: _buildDropdownButtonWidget(isDropdownOpen))
            : _buildDropdownButtonWidget(isDropdownOpen),
        if (errorText.isNotEmpty)
          Padding(
            padding: padding(top: 8.h),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                errorText,
                style: StyleThemeData.size12Weight400(color: appTheme.errorColor),
              ),
            ),
          ),
      ],
    );
  }

  DropdownButtonHideUnderline _buildDropdownButtonWidget(RxBool isDropdownOpen) {
    return DropdownButtonHideUnderline(
      child: AbsorbPointer(
        absorbing: !canOpen,
        child: DropdownButton2<T>(
          isExpanded: isExpanded,
          hint: Text(
            hintText ?? '',
            style: StyleThemeData.size14Weight700(color: appTheme.gray78Color),
          ),
          items: items.map((item) {
            return DropdownItem<T>(
              value: item,
              child: Text(
                itemAsString(item),
                style: StyleThemeData.size14Weight400(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: enabled ? (value) => onChanged?.call(value) : null,
          customButton: Container(
            padding: paddingCustom ?? padding(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusBorder),
              border: Border.all(
                color: errorText.isNotEmpty ? appTheme.errorColor : appTheme.transparentColor,
                width: 1.w,
              ),
              color: errorText.isNotEmpty
                  ? appTheme.errorColor.withSafeOpacity(.1)
                  : backgroundColor ?? appTheme.grayF3Color,
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[prefixIcon!, SizedBox(width: 8.w)],
                Expanded(
                  child: Padding(
                    padding: padding(right: 12),
                    child: Text(
                      selectedItem != null ? itemAsString(selectedItem as T) : (hintText ?? ''),
                      style: styleSelected?.copyWith(
                            color: selectedItem != null ? appTheme.blackColor : appTheme.gray78Color,
                          ) ??
                          StyleThemeData.size14Weight400(
                            color: selectedItem != null ? appTheme.blackColor : appTheme.gray78Color,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (canOpen)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (suffixIcon != null) ...[suffixIcon!, SizedBox(width: 8.w)],
                      if (isLoading)
                        SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation(appTheme.appColor),
                          ),
                        )
                      else
                        Obx(
                          () => isDropdownOpen.value
                              ? Transform.rotate(
                                  angle: 3.1416,
                                  child: Assets.icons.arrowDown.svg(
                                    width: 18.w,
                                    height: 18.w,
                                    colorFilter: ColorFilter.mode(appTheme.grayColor, BlendMode.srcIn),
                                  ),
                                )
                              : Assets.icons.arrowDown.svg(
                                  width: 18.w,
                                  height: 18.w,
                                  colorFilter: ColorFilter.mode(appTheme.grayColor, BlendMode.srcIn),
                                ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 400.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: appTheme.grayE6Color, width: 1.w),
              color: appTheme.whiteColor,
            ),
            offset: const Offset(0, -10),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all(6),
              thumbVisibility: WidgetStateProperty.all(true),
              thumbColor: WidgetStateProperty.all(
                appTheme.grayColor.withSafeOpacity(0.4),
              ),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return null;
              if (states.contains(WidgetState.selected)) {
                return appTheme.appColor.withSafeOpacity(0.1);
              }
              if (states.contains(WidgetState.hovered) || states.contains(WidgetState.focused)) {
                return appTheme.appColor.withSafeOpacity(0.06);
              }
              return null;
            }),
          ),
          buttonStyleData: ButtonStyleData(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(radiusBorder)),
          ),
          onMenuStateChange: (isOpen) {
            isDropdownOpen.value = isOpen;
          },
        ),
      ),
    );
  }
}
