import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final upperCaseText = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upperCaseText,
      selection: newValue.selection,
    );
  }
}
