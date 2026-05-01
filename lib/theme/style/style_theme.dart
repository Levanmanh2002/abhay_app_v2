import 'package:abhay_app_v2/gen/fonts.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';

class StyleThemeData {
  static TextStyle size10Weight400({Color? color, double height = 1.5, String? fontFamily}) => TextStyle(
        fontSize: 10.fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: fontFamily ?? FontFamily.sFUIDisplayRegular,
      );

  static TextStyle size10Weight700({Color? color, double height = 1.5}) => TextStyle(
        fontSize: 10.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: FontFamily.sFUIDisplayBold,
      );

  static TextStyle size12Weight400({Color? color, double height = 1.5, String? fontFamily}) => TextStyle(
        fontSize: 12.fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: fontFamily ?? FontFamily.sFUIDisplayRegular,
      );

  static TextStyle size12Weight700({Color? color, double height = 1.5, String? fontFamily}) => TextStyle(
        fontSize: 12.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: fontFamily ?? FontFamily.sFUIDisplayBold,
      );

  static TextStyle size14Weight400({Color? color, double height = 1.5, String? fontFamily}) => TextStyle(
        fontSize: 14.fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: fontFamily ?? FontFamily.sFUIDisplayRegular,
      );

  static TextStyle size14Weight700({Color? color, double height = 1.5, String? fontFamily}) => TextStyle(
        fontSize: 14.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: fontFamily ?? FontFamily.sFUIDisplayBold,
      );

  static TextStyle size16Weight400({BuildContext? context, Color? color, double height = 1.5}) => TextStyle(
        fontSize: 16.fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? appTheme.blackColor,
        height: height.h,
        letterSpacing: 0.2,
        fontFamily: FontFamily.sFUIDisplayRegular,
      );

  static TextStyle size16Weight700({Color? color, double height = 1.5}) => TextStyle(
        fontSize: 16.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: FontFamily.sFUIDisplayBold,
      );

  static TextStyle size18Weight700({Color? color, double height = 1.5}) => TextStyle(
        fontSize: 18.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: FontFamily.sFUIDisplayBold,
      );

  static TextStyle size20Weight700({Color? color, double height = 1.5}) => TextStyle(
        fontSize: 20.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: FontFamily.sFUIDisplayBold,
      );

  static TextStyle size24Weight700({Color? color, double height = 1.5}) => TextStyle(
        fontSize: 24.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: FontFamily.sFUIDisplayBold,
      );

  static TextStyle size28Weight700({Color? color, double height = 1.5}) => TextStyle(
        fontSize: 28.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: FontFamily.sFUIDisplayBold,
      );

  static TextStyle size36Weight700({Color? color, double height = 1.5}) => TextStyle(
        fontSize: 36.fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? appTheme.blackColor,
        height: height.h,
        fontFamily: FontFamily.sFUIDisplayBold,
      );
}
