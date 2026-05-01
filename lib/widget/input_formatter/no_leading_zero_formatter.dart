import 'package:flutter/services.dart';

class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isNotEmpty && text.startsWith('0')) {
      return oldValue;
    }

    if (text.isEmpty && newValue.text == '0') {
      return oldValue;
    }

    return newValue;
  }
}
