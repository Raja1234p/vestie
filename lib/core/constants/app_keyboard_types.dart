import 'package:flutter/services.dart';

/// Shared numeric [TextInputType] presets — use instead of [TextInputType.number].
abstract final class AppKeyboardTypes {
  AppKeyboardTypes._();

  /// Money / amounts that may include cents (goal $, borrow $, etc.).
  static const decimal = TextInputType.numberWithOptions(
    decimal: true,
    signed: false,
  );

  /// Whole numbers only — days, OTP, %, counts (no `.` on the keypad).
  static const integer = TextInputType.numberWithOptions(
    decimal: false,
    signed: false,
  );
}
