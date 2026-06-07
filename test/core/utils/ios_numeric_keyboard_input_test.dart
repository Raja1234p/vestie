import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/utils/ios_numeric_keyboard_input.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('Android / web — no workaround', () {
    test('Android keeps number keyboard and formatters', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(
        IosNumericKeyboardInput.needsDoneWorkaround(
          keyboardType: TextInputType.number,
          isMultiline: false,
          textInputAction: TextInputAction.done,
        ),
        isFalse,
      );
      expect(
        IosNumericKeyboardInput.effectiveKeyboardType(
          keyboardType: TextInputType.number,
          isMultiline: false,
          textInputAction: TextInputAction.done,
        ),
        TextInputType.number,
      );
      expect(
        IosNumericKeyboardInput.effectiveFormatters(
          keyboardType: TextInputType.number,
          isMultiline: false,
          textInputAction: TextInputAction.done,
        ),
        isEmpty,
      );
      expect(
        IosNumericKeyboardInput.shouldDisableTextAssist(
          keyboardType: TextInputType.number,
          isMultiline: false,
          textInputAction: TextInputAction.done,
        ),
        isFalse,
      );
    });

    test('numberWithOptions decimal unchanged on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      const keyboardType = TextInputType.numberWithOptions(decimal: true);

      expect(
        IosNumericKeyboardInput.effectiveKeyboardType(
          keyboardType: keyboardType,
          isMultiline: false,
          textInputAction: TextInputAction.next,
        ),
        keyboardType,
      );
    });
  });

  group('iOS — workaround only for numeric fields', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    test('number keyboard swaps to text with digits-only formatter', () {
      expect(
        IosNumericKeyboardInput.effectiveKeyboardType(
          keyboardType: TextInputType.number,
          isMultiline: false,
          textInputAction: TextInputAction.done,
        ),
        TextInputType.text,
      );

      final formatters = IosNumericKeyboardInput.effectiveFormatters(
        keyboardType: TextInputType.number,
        isMultiline: false,
        textInputAction: TextInputAction.done,
      );
      expect(formatters, hasLength(1));
      expect(formatters.first, isA<FilteringTextInputFormatter>());
    });

    test('preserves custom formatters (ROI, voting window)', () {
      final custom = [PercentDigitsInputFormatter()];
      final formatters = IosNumericKeyboardInput.effectiveFormatters(
        keyboardType: TextInputType.number,
        isMultiline: false,
        textInputAction: TextInputAction.done,
        inputFormatters: custom,
      );
      expect(formatters, custom);
    });

    test('decimal pad gets decimal formatter when none provided', () {
      const keyboardType = TextInputType.numberWithOptions(decimal: true);
      final formatters = IosNumericKeyboardInput.effectiveFormatters(
        keyboardType: keyboardType,
        isMultiline: false,
        textInputAction: TextInputAction.next,
      );
      expect(formatters, hasLength(1));
    });

    test('skips multiline and non-numeric fields', () {
      expect(
        IosNumericKeyboardInput.needsDoneWorkaround(
          keyboardType: null,
          isMultiline: false,
          textInputAction: TextInputAction.next,
        ),
        isFalse,
      );
      expect(
        IosNumericKeyboardInput.needsDoneWorkaround(
          keyboardType: TextInputType.emailAddress,
          isMultiline: false,
          textInputAction: TextInputAction.next,
        ),
        isFalse,
      );
      expect(
        IosNumericKeyboardInput.needsDoneWorkaround(
          keyboardType: TextInputType.number,
          isMultiline: true,
          textInputAction: TextInputAction.done,
        ),
        isFalse,
      );
    });
  });
}

/// Minimal stand-in so this test file does not import leader feature code.
class PercentDigitsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue;
}
