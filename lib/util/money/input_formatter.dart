import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final regex = RegExp(r'^-?\d+\.?\d{0,2}$');
    if (regex.hasMatch(text)) return newValue;

    final negative = text.startsWith('-');
    final cleaned = text.replaceAll(RegExp(r'[^\d.]'), '');
    final dotIndex = cleaned.indexOf('.');

    if (dotIndex == -1) {
      final result = '${negative ? '-' : ''}$cleaned';
      return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }

    final integerPart = cleaned.substring(0, dotIndex);
    final decimalPart = cleaned.substring(dotIndex + 1).replaceAll('.', '');
    final finalText =
        '${negative ? '-' : ''}$integerPart.${decimalPart.substring(0, decimalPart.length.clamp(0, 2))}';
    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}
