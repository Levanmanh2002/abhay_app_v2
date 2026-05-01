import 'package:flutter/services.dart';

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Remove all non-digit characters
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    // Format the number with a dot every 3 digits
    StringBuffer formattedText = StringBuffer();
    int length = newText.length;

    if (length > 3) {
      int firstPartLength = length % 3;
      if (firstPartLength > 0) {
        formattedText.write(newText.substring(0, firstPartLength));
        formattedText.write('.');
      }
      for (int i = firstPartLength; i < length; i += 3) {
        formattedText.write(newText.substring(i, i + 3));
        if (i + 3 < length) {
          formattedText.write('.');
        }
      }
    } else {
      formattedText.write(newText);
    }

    // Return the new text with the formatted string
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
