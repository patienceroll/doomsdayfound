import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final regex = RegExp(r'^\d+\.?\d{0,2}$');
    if (regex.hasMatch(text)) return newValue;

    final dotIndex = text.indexOf('.');
    if (dotIndex == -1) {
      return TextEditingValue(
        text: text.replaceAll(RegExp(r'[^\d]'), ''),
        selection: newValue.selection,
      );
    }

    final integerPart =
        text.substring(0, dotIndex).replaceAll(RegExp(r'[^\d]'), '');
    final decimalPart =
        text.substring(dotIndex + 1).replaceAll(RegExp(r'[^\d]'), '');
    final finalText =
        '$integerPart.${decimalPart.substring(0, decimalPart.length.clamp(0, 2))}';
    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}
