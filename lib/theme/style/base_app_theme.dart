import 'package:abhay_app_v2/theme/base_theme_data.dart';
import 'package:flutter/material.dart';

enum ThemeType { light, dark }

abstract class BaseAppTheme<A extends BaseThemeData, B extends BaseThemeData> {
  A get lightTheme;

  B get darkTheme;

  late final ThemeData _lightTheme = ThemeData(
    primaryColor: lightTheme.primaryColor,
    dividerColor: lightTheme.dividerColor,
    hintColor: lightTheme.hintColor,
    bottomAppBarTheme: BottomAppBarTheme(color: lightTheme.primaryColor),
    cardColor: lightTheme.backgroundContainer,
  );

  late final ThemeData _darkTheme = ThemeData(
    primaryColor: darkTheme.primaryColor,
    dividerColor: darkTheme.dividerColor,
    hintColor: darkTheme.hintColor,
    bottomAppBarTheme: BottomAppBarTheme(color: darkTheme.primaryColor),
    cardColor: darkTheme.backgroundContainer,
  );

  ThemeData getThemeData(ThemeType type) {
    if (type == ThemeType.light) {
      return _lightTheme;
    } else {
      return _darkTheme;
    }
  }

  BaseThemeData getBaseTheme(ThemeType type) {
    if (type == ThemeType.light) {
      return lightTheme;
    } else {
      return darkTheme;
    }
  }
}
