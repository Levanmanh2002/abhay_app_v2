import 'package:flutter/services.dart';

class CommaSeparatedNumberFormatter extends TextInputFormatter {
  final int maxCommas; // Giới hạn số dấu phẩy

  CommaSeparatedNumberFormatter({this.maxCommas = 1}); // Mặc định chỉ 1 dấu phẩy

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Không cho bắt đầu bằng dấu phẩy
    if (text.startsWith(',')) return oldValue;

    // Không cho 2 dấu phẩy liên tiếp
    if (text.contains(',,')) return oldValue;

    // Không cho khoảng trắng
    if (text.contains(' ')) return oldValue;

    // Giới hạn số dấu phẩy
    if (','.allMatches(text).length > maxCommas) return oldValue;

    final parts = text.split(',');

    for (final part in parts) {
      if (part.isEmpty) continue;

      // Chặn số 0 đứng đầu (01, 02,...)
      if (part.length > 1 && part.startsWith('0')) {
        final fixed = parts.map((p) => (p.length > 1 && p.startsWith('0')) ? p.substring(1) : p).join(',');
        return newValue.copyWith(
          text: fixed,
          selection: TextSelection.collapsed(offset: fixed.length),
        );
      }
    }

    return newValue;
  }
}
