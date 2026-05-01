import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final bool showSymbol;
  final String symbol;

  CurrencyInputFormatter({this.showSymbol = true, this.symbol = '₫'});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    // Remove all non-digit characters
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    // Format with dot every 3 digits
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

    // Append currency symbol (optional)
    if (showSymbol && symbol.isNotEmpty) {
      formattedText.write(symbol);
    }

    // Cursor position: nếu có symbol thì đứng trước symbol
    final offset = formattedText.length - (showSymbol ? 1 : 0);

    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: offset < 0 ? 0 : offset),
    );
  }
}
