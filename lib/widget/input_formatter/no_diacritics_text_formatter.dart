import 'package:flutter/services.dart';

class NoDiacriticsTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Loại bỏ các ký tự có dấu
    String newText = newValue.text
        .replaceAll(RegExp(r'[ăâáàảãạằắẳẵặấầẩẫậêéèẻẽẹềếểễệîíìỉĩịôơóòỏõọốồổỗộớờởỡợưúùủũụứừửữựýỳỷỹỵđ]'), '')
        .replaceAll(RegExp(r'[ĂÂÁÀẢÃẠẰẮẲẴẶẤẦẨẪẬÊÉÈẺẼẸỀẾỂỄỆÎÍÌỈĨỊÔƠÓÒỎÕỌỐỒỔỖỘỚỜỞỠỢƯÚÙỦŨỤỨỪỬỮỰÝỲỶỸỴĐ]'), '');

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
