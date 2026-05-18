import 'package:flutter/services.dart';

/// Profile username / handle — letters, numbers, symbols; no whitespace; max 50.
class UsernameInputFormatter extends TextInputFormatter {
  const UsernameInputFormatter();

  static const int maxLength = 50;

  /// Value sent to API / [ValidationUtils.validateProfileUsernameHandle].
  static String normalize(String raw) =>
      raw.trim().replaceFirst(RegExp(r'^@+'), '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'\s'), '');
    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }
    if (text == newValue.text) return newValue;

    final end = newValue.selection.end.clamp(0, text.length);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: end),
    );
  }
}
