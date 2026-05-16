import 'package:flutter/services.dart';

import '../constants/app_strings.dart';

/// Shows up to [maxDigits] with a trailing [AppStrings.percentSign] (e.g. `10%`).
/// State/API should store digits only via [TextEditingValue.text] stripped of `%`.
class PercentDigitsInputFormatter extends TextInputFormatter {
  PercentDigitsInputFormatter({this.maxDigits = 3});

  final int maxDigits;

  static final _nonDigit = RegExp(r'[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(_nonDigit, '');
    final oldDigits = oldValue.text.replaceAll(_nonDigit, '');

    if (newValue.text.length < oldValue.text.length &&
        digits.length == oldDigits.length &&
        oldDigits.isNotEmpty) {
      digits = oldDigits.substring(0, oldDigits.length - 1);
    } else if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final display = '$digits${AppStrings.percentSign}';
    var offset = newValue.selection.baseOffset;
    if (offset > digits.length) offset = digits.length;
    if (offset < 0) offset = 0;

    return TextEditingValue(
      text: display,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
