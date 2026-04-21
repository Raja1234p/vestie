import 'validation_utils.dart';

/// Deprecated compatibility wrapper.
/// Use `ValidationUtils` directly for all new code.
@Deprecated('Use ValidationUtils instead')
class AppValidators {
  AppValidators._();

  static final RegExp _phoneRegExp = RegExp(r'^\+?[1-9]\d{1,14}$');

  static String? validateEmail(String? value) =>
      ValidationUtils.validateEmail(value);

  static String? validatePassword(String? value) =>
      ValidationUtils.validatePassword(value);

  static String? validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    if (!_phoneRegExp.hasMatch(v)) return 'Please enter a valid phone number';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName is required';
    return null;
  }
}
