import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS number/decimal pads have no Return/Done key; [TextInputAction] is
/// ignored (flutter/flutter#12220). Swap to the text keyboard + formatters.
abstract final class IosNumericKeyboardInput {
  static bool isNumericKeyboardType(TextInputType? keyboardType) {
    if (keyboardType == null) return false;
    return keyboardType.index == TextInputType.number.index;
  }

  static bool needsDoneWorkaround({
    required TextInputType? keyboardType,
    required bool isMultiline,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS || isMultiline) {
      return false;
    }
    if (!isNumericKeyboardType(keyboardType)) return false;
    return textInputAction != TextInputAction.none &&
        textInputAction != TextInputAction.unspecified;
  }

  static TextInputType effectiveKeyboardType({
    required TextInputType? keyboardType,
    required bool isMultiline,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    if (isMultiline) return TextInputType.multiline;
    if (needsDoneWorkaround(
      keyboardType: keyboardType,
      isMultiline: isMultiline,
      textInputAction: textInputAction,
    )) {
      return TextInputType.text;
    }
    return keyboardType ?? TextInputType.text;
  }

  /// Text keyboard shows autocorrect/caps unless disabled (iOS workaround only).
  static bool shouldDisableTextAssist({
    required TextInputType? keyboardType,
    required bool isMultiline,
    TextInputAction textInputAction = TextInputAction.next,
  }) =>
      needsDoneWorkaround(
        keyboardType: keyboardType,
        isMultiline: isMultiline,
        textInputAction: textInputAction,
      );

  static List<TextInputFormatter> effectiveFormatters({
    required TextInputType? keyboardType,
    required bool isMultiline,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final workaround = needsDoneWorkaround(
      keyboardType: keyboardType,
      isMultiline: isMultiline,
      textInputAction: textInputAction,
    );
    if (!workaround) return inputFormatters ?? const [];

    final usesDecimalPad = keyboardType?.decimal ?? false;
    return <TextInputFormatter>[
      if (inputFormatters == null || inputFormatters.isEmpty)
        usesDecimalPad
            ? _DecimalDigitsInputFormatter()
            : FilteringTextInputFormatter.digitsOnly,
      ...?inputFormatters,
    ];
  }
}

/// Digits with at most one decimal separator (for iOS decimal-pad workaround).
class _DecimalDigitsInputFormatter extends TextInputFormatter {
  static final _pattern = RegExp(r'^\d*\.?\d*');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_pattern.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}
