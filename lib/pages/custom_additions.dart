import 'package:flutter/services.dart';

class EndSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isNotEmpty && !text.endsWith(' ')) {
      return TextEditingValue(
        text: '$text ',
        selection: TextSelection.fromPosition(
          TextPosition(offset: text.length),
        ),
      );
    }
    return newValue;
  }
}
