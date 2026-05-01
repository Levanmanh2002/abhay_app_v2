import 'package:abhay_app_v2/theme/base_theme_data.dart';
import 'package:abhay_app_v2/theme/style/base_app_theme.dart';
import 'package:flutter/material.dart';

class AppThemeDefault extends BaseAppTheme<AppLightThemeDefault, AppDartThemeDefault> {
  @override
  AppDartThemeDefault get darkTheme => AppDartThemeDefault();

  @override
  AppLightThemeDefault get lightTheme => AppLightThemeDefault();
}

class AppLightThemeDefault extends BaseThemeData {
  @override
  Color get primaryColor => const Color(0xFF0F172A);

  @override
  Color get secondaryColor => const Color(0xFFFF9F29);

  @override
  Color get primaryTextColor => Colors.white;

  @override
  Color get thirdColor => const Color(0xFF0F172A);

  @override
  Color get fadeTextColor => const Color(0xFF94A3B8);
}

class AppDartThemeDefault extends BaseThemeData {
  @override
  Color get background => const Color(0xFF0F172A);

  @override
  Color get fadeTextColor => const Color(0xFF64748B);

  @override
  Color get primaryTextColor => const Color(0xFF0F172A);

  @override
  Color get secondaryTextColor => const Color(0xFFFF9F29);

  @override
  Color get primaryColor => Colors.white;
}
