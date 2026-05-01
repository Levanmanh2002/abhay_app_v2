import 'package:abhay_app_v2/theme/base_theme_data.dart';
import 'package:abhay_app_v2/theme/style/base_app_theme.dart';
import 'package:abhay_app_v2/theme/theme.dart';
import 'package:flutter/material.dart';

class AppThemeUtil {
  final theme = AppThemeDefault();

  final ValueNotifier<ThemeType> themeType = ValueNotifier(ThemeType.light);

  BaseAppTheme get appTheme => theme;

  void dispose() {
    themeType.dispose();
  }

  ThemeData getThemeData() {
    return theme.getThemeData(themeType.value);
  }

  BaseThemeData getAppTheme() {
    return theme.getBaseTheme(themeType.value);
  }

  void onChangeLightDarkMode() {
    if (themeType.value == ThemeType.light) {
      themeType.value = ThemeType.dark;
    } else {
      themeType.value = ThemeType.light;
    }
  }
}
