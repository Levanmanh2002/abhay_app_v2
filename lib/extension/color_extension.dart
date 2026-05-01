import 'dart:ui';

import 'package:flutter/material.dart';

extension SafeOpacityExtension on Color {
  Color withSafeOpacity(double opacity) {
    assert(opacity >= 0 && opacity <= 1, 'Opacity must be between 0 and 1.');
    return withAlpha((opacity * 255).round());
  }

  static int floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  int get toInt32 {
    return floatToInt8(a) << 24 | floatToInt8(r) << 16 | floatToInt8(g) << 8 | floatToInt8(b) << 0;
  }
}

extension HexColorExtension on String {
  Color get toColor {
    final hex = replaceAll('#', '');
    return Color(int.parse('0xFF$hex'));
  }
}
