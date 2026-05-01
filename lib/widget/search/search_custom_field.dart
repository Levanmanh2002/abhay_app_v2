import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:abhay_app_v2/widget/search/clear_icon_text.dart';
import 'package:abhay_app_v2/widget/search/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchCustomField extends StatefulWidget {
  const SearchCustomField({
    super.key,
    required this.onGetSearchValue,
    this.hintText,
    this.paddingTextfield,
    this.getSearchStatus,
    this.backgroundColor,
    this.hintStyle,
    this.hasBorder = false,
    this.textStyle,
    this.initialText,
    this.prefixIcon,
    this.margin,
    this.focusNode,
    this.textController,
    this.radius,
    this.icon,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.enableDebounce = true,
  });

  final EdgeInsets? paddingTextfield;
  final EdgeInsets? margin;
  final String? hintText;
  final void Function(String) onGetSearchValue;
  final void Function(bool)? getSearchStatus;
  final bool hasBorder;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final String? initialText;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final TextEditingController? textController;
  final double? radius;
  final Widget? icon;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final bool enableDebounce;

  @override
  State<SearchCustomField> createState() => _SearchCustomFieldState();
}

class _SearchCustomFieldState extends State<SearchCustomField> {
  late final controller = widget.textController ?? TextEditingController(text: widget.initialText);
  late final _searchCtrl = SearchStreamController(
    onGetValue: widget.onGetSearchValue,
    updateSearchingStatus: widget.getSearchStatus,
    enableDebounce: widget.enableDebounce,
  );

  @override
  void dispose() {
    controller.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: CustomTextField(
        controller: controller,
        hintText: 'search'.tr,
        isRequired: false,
        borderRadius: widget.radius ?? 30,
        showBorder: false,
        fillColor: widget.backgroundColor ?? appTheme.grayF3Color,
        contentPadding: widget.paddingTextfield ?? padding(all: 12),
        focusNode: widget.focusNode,
        hintStyle: widget.hintStyle ?? StyleThemeData.size14Weight400(color: appTheme.gray78Color),
        textStyle: widget.textStyle,
        prefixIcon: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [widget.prefixIcon ?? Assets.icons.searchNormal.svg(width: 22.w, height: 22.w)],
        ),
        suffixIcon: ClearIconText(
          controller: controller,
          handleAfterClear: () => _searchCtrl.insertNewText(''),
          icon: widget.icon,
        ),
        prefixIconConstraints: widget.prefixIconConstraints,
        suffixIconConstraints: widget.suffixIconConstraints,
        onChanged: _searchCtrl.insertNewText,
      ),
    );
  }
}
