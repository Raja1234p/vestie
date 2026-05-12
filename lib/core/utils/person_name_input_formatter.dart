import 'package:characters/characters.dart';
import 'package:flutter/services.dart';

/// Letters (+ optional spaces) only — no digits, symbols, @, or emoji.
/// Use for legal full name, card holder, and similar fields.
class PersonNameInputFormatter extends TextInputFormatter {
  const PersonNameInputFormatter({this.allowSpaces = true});

  final bool allowSpaces;

  /// Normalizes [raw] (strip leading `@`) then checks every grapheme is allowed.
  static bool isValidTrimmed(String raw, {required bool allowSpaces}) {
    final t = raw.trim().replaceFirst(RegExp(r'^@+'), '');
    if (t.isEmpty) return true;
    return _filterText(t, allowSpaces) == t;
  }

  static String _filterText(String input, bool allowSpaces) {
    final out = StringBuffer();
    for (final g in input.characters) {
      if (allowSpaces && g == ' ') {
        out.write(' ');
        continue;
      }
      if (_graphemeIsLetterCluster(g)) out.write(g);
    }
    return out.toString();
  }

  static bool _graphemeIsLetterCluster(String g) {
    var hasLetter = false;
    for (final r in g.runes) {
      if (r == 0x20) return false;
      if (_isCombiningMark(r)) continue;
      if (_isLetterRune(r)) {
        hasLetter = true;
        continue;
      }
      return false;
    }
    return hasLetter;
  }

  static bool _isCombiningMark(int r) =>
      (r >= 0x0300 && r <= 0x036F) ||
      (r >= 0x1AB0 && r <= 0x1AFF) ||
      (r >= 0x1DC0 && r <= 0x1DFF);

  static bool _isLetterRune(int r) {
    if ((r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A)) return true;
    if (r >= 0x00C0 && r <= 0x024F) return true;
    if (r >= 0x0400 && r <= 0x04FF) return true;
    if (r >= 0x0530 && r <= 0x058F) return true;
    if (r >= 0x0600 && r <= 0x06FF) return true;
    if (r >= 0x0900 && r <= 0x0AFF) return true;
    if (r >= 0x3040 && r <= 0x309F) return true;
    if (r >= 0x30A0 && r <= 0x30FF) return true;
    if (r >= 0x4E00 && r <= 0x9FFF) return true;
    if (r >= 0xAC00 && r <= 0xD7AF) return true;
    return false;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = _filterText(newValue.text, allowSpaces);
    if (filtered == newValue.text) return newValue;
    final max = filtered.length;
    var end = newValue.selection.end;
    if (end > max) end = max;
    if (end < 0) end = 0;
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: end),
    );
  }
}
