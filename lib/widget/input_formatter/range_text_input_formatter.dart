import 'package:flutter/services.dart';

class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeTextInputFormatter({this.min = 1, this.max = 100});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final intValue = int.tryParse(newValue.text) ?? 0;
    if (intValue < min) {
      return oldValue;
    } else if (intValue > max) {
      return oldValue;
    } else {
      return newValue;
    }
  }
}
