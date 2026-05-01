import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/image_asset_custom.dart';
import 'package:abhay_app_v2/widget/input_formatter/no_initial_space_input_formatter_widgets.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../main.dart';

class CustomTextField extends StatefulWidget {
  final String initialValue;
  final String titleText;
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final bool isStatus;
  final ValueChanged<String>? onChanged;
  final Function? onSubmit;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign textAlign;
  final bool isAmount;
  final bool isNumber;
  final bool showBorder;
  final double iconSize;
  final bool isRequired;
  final double? borderRadius;
  final Color? colorStyle;
  final Color? colorBorder;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool readOnly;
  final VoidCallback? onTap;
  final String Function(String)? onValidate;
  final Future<String> Function(String)? onValidateAsync;
  final int? maxLength;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final String errorText;
  final TextStyle? titleStyle;
  final String iconInput;
  final AlignmentGeometry? alignmentError;
  final Color? colorLine;
  final List<TextInputFormatter>? inputFormatters;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final Color? cursorColor;
  final double cursorWidth;

  const CustomTextField({
    super.key,
    this.initialValue = '',
    this.titleText = '',
    this.hintText = '',
    this.labelText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmit,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.isStatus = false,
    this.textAlign = TextAlign.start,
    this.isAmount = false,
    this.isNumber = false,
    this.showBorder = true,
    this.iconSize = 18,
    this.isRequired = true,
    this.borderRadius,
    this.colorStyle,
    this.colorBorder,
    this.fillColor,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.readOnly = false,
    this.onTap,
    this.onValidate,
    this.maxLength,
    this.onValidateAsync,
    this.floatingLabelBehavior,
    this.errorText = '',
    this.titleStyle,
    this.iconInput = '',
    this.alignmentError,
    this.colorLine,
    this.inputFormatters,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.cursorColor,
    this.cursorWidth = 2.0,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  final ValueNotifier<String> _validate = ValueNotifier<String>('');
  final ValueNotifier<bool> _obscureText = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _obscureText.dispose();
    _validate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.titleText.isNotEmpty
            ? Padding(
                padding: padding(bottom: 8),
                child: Row(
                  children: [
                    Text(widget.titleText, style: widget.titleStyle ?? StyleThemeData.size14Weight700()),
                    if (widget.isRequired) ...[
                      SizedBox(width: 4.w),
                      Text('*', style: StyleThemeData.size14Weight700(color: appTheme.errorColor)),
                    ],
                  ],
                ),
              )
            : const SizedBox(),
        Row(
          children: [
            if (widget.iconInput.isNotEmpty) ...[
              ImageAssetCustom(imagePath: widget.iconInput, size: 18.w),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: ValueListenableBuilder<bool>(
                  valueListenable: _obscureText,
                  builder: (context, isObscured, child) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _validate,
                      builder: (context, validateValue, child) {
                        return TextField(
                          controller: widget.initialValue.isNotEmpty
                              ? TextEditingController(text: widget.initialValue)
                              : widget.controller,
                          maxLines: widget.maxLines,
                          readOnly: widget.readOnly,
                          onTap: widget.onTap,
                          focusNode: widget.focusNode,
                          textAlign: widget.textAlign,
                          style: widget.textStyle ?? StyleThemeData.size16Weight400(),
                          textInputAction: widget.inputAction,
                          keyboardType: widget.isAmount ? TextInputType.number : widget.inputType,
                          cursorColor: widget.cursorColor ?? appTheme.appColor,
                          cursorWidth: widget.cursorWidth,
                          textCapitalization: widget.capitalization,
                          enabled: widget.isEnabled,
                          autofocus: false,
                          obscureText: widget.isPassword ? isObscured : false,
                          maxLength: widget.maxLength,
                          inputFormatters: (widget.inputType == TextInputType.phone
                              ? <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ...widget.inputFormatters ?? [],
                                ]
                              : widget.inputType == TextInputType.number
                                  ? <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                      ...widget.inputFormatters ?? [],
                                    ]
                                  : widget.isAmount
                                      ? [
                                          FilteringTextInputFormatter.allow(RegExp(r'\d')),
                                          FilteringTextInputFormatter.deny(RegExp(r'\s\s\s+')),
                                        ]
                                      : widget.isNumber
                                          ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))]
                                          : <TextInputFormatter>[
                                              NoInitialSpaceInputFormatter(),
                                              FilteringTextInputFormatter.deny(RegExp(r'\s\s\s+')),
                                              ...widget.inputFormatters ?? [],
                                            ]),
                          decoration: InputDecoration(
                            floatingLabelBehavior: widget.floatingLabelBehavior,
                            counterStyle: const TextStyle(height: double.minPositive),
                            counterText: '',
                            contentPadding: widget.contentPadding ?? padding(all: 16),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                              borderSide: BorderSide(
                                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                                width: 1.w,
                                color: (widget.errorText.isNotEmpty || validateValue.isNotEmpty)
                                    ? appTheme.errorColor
                                    : widget.colorBorder ?? appTheme.grayE6Color,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                              borderSide: BorderSide(
                                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                                width: 1.w,
                                color: (widget.errorText.isNotEmpty || validateValue.isNotEmpty)
                                    ? appTheme.errorColor
                                    : widget.colorBorder ?? appTheme.appColor,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                              borderSide: BorderSide(
                                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                                width: 1.w,
                                color: (widget.errorText.isNotEmpty || validateValue.isNotEmpty)
                                    ? appTheme.errorColor
                                    : widget.colorBorder ?? appTheme.grayE6Color,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                              borderSide: BorderSide(
                                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                                width: 1.w,
                                color: (widget.errorText.isNotEmpty || validateValue.isNotEmpty)
                                    ? appTheme.errorColor
                                    : widget.colorBorder ?? appTheme.grayE6Color,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                              borderSide: BorderSide(
                                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                                width: 1.w,
                                color: widget.colorBorder ?? appTheme.errorColor,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                              borderSide: BorderSide(
                                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                                width: 1.w,
                                color: widget.colorBorder ?? appTheme.errorColor,
                              ),
                            ),
                            isDense: true,
                            hintText: widget.hintText,
                            labelText: widget.labelText,
                            labelStyle: StyleThemeData.size12Weight400(color: appTheme.grayE6Color),
                            fillColor: widget.fillColor ?? appTheme.whiteColor,
                            hintStyle: widget.hintStyle ??
                                StyleThemeData.size14Weight400(color: widget.colorStyle ?? appTheme.gray78Color),
                            filled: true,
                            prefixIcon: widget.prefixIcon,
                            // suffixIcon: widget.suffixIcon,
                            suffixIcon: widget.isPassword
                                ? IconButton(
                                    icon: SvgPicture.asset(
                                      isObscured ? Assets.icons.eyeSlash.path : Assets.icons.eye.path,
                                    ),
                                    onPressed: _toggle,
                                  )
                                : (widget.suffixIcon != null)
                                    ? widget.suffixIcon
                                    : null,
                            prefixIconConstraints: widget.prefixIconConstraints,
                            suffixIconConstraints: widget.suffixIconConstraints,
                          ),
                          onSubmitted: (text) => widget.nextFocus != null
                              ? FocusScope.of(context).requestFocus(widget.nextFocus)
                              : widget.onSubmit != null
                                  ? widget.onSubmit!(text)
                                  : null,
                          onChanged: (value) {
                            _onValidate(value);
                            return widget.onChanged?.call(value);
                          },
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
        ValueListenableBuilder<String>(
          valueListenable: _validate,
          builder: (context, validateMessage, child) {
            return (widget.errorText.isEmpty && validateMessage.isNotEmpty)
                ? Padding(
                    padding: padding(top: 8.h),
                    child: Align(
                      alignment: widget.alignmentError ?? Alignment.centerRight,
                      child: Text(
                        validateMessage,
                        style: StyleThemeData.size12Weight400(color: appTheme.errorColor),
                      ),
                    ),
                  )
                : widget.errorText.isNotEmpty
                    ? Padding(
                        padding: padding(top: 8.h),
                        child: Align(
                          alignment: widget.alignmentError ?? Alignment.centerRight,
                          child: Text(
                            widget.errorText,
                            style: StyleThemeData.size12Weight400(color: appTheme.errorColor),
                          ),
                        ),
                      )
                    : const SizedBox();
          },
        ),
      ],
    );
  }

  void _toggle() {
    _obscureText.value = !_obscureText.value;
  }

  Future<void> _onValidate(String value) async {
    String validationMessage = '';
    if (widget.onValidate != null) {
      validationMessage = widget.onValidate!(value);
    } else if (widget.onValidateAsync != null) {
      validationMessage = await widget.onValidateAsync!(value);
    }
    if (_validate.value != validationMessage) {
      _validate.value = validationMessage;
    }
  }
}
