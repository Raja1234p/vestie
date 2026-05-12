import 'validation_utils.dart';

class Validators {
  static const String emailRequiredMsg = 'Email is required';
  static const String emailInvalidMsg = 'Enter a valid email address';
  static const String passwordRequiredMsg = 'Password is required';
  static const String passwordShortMsg = 'Password must be at least 8 characters long';
  static const String passwordFormatMsg = 'Password must contain at least one letter and one number';
  static const String amountRequiredMsg = 'Amount is required';
  static const String amountInvalidMsg = 'Enter a valid amount';

  static const String emailRegex = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static const String amountRegex = r'^\d+(\.\d{1,2})?$';

  // central validation aliases matching user requirements
  static String? email(String? value) => validateEmail(value);
  static String? password(String? value) => validatePassword(value);
  static String? amount(String? value, {double? min, double? max}) => validateAmount(value, min: min, max: max);
  static String? name(String? value) => validateRequired(value, 'Name');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return emailRequiredMsg;
    }
    if (!RegExp(emailRegex).hasMatch(value)) {
      return emailInvalidMsg;
    }
    return null;
  }

  static String? validatePassword(String? value) =>
      ValidationUtils.validatePassword(value);

  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return amountRequiredMsg;
    }
    if (!RegExp(amountRegex).hasMatch(value)) {
      return amountInvalidMsg;
    }
    
    final amt = double.tryParse(value);
    if (amt == null) {
      return amountInvalidMsg;
    }
    if (min != null && amt < min) {
      return 'Minimum amount is $min';
    }
    if (max != null && amt > max) {
      return 'Maximum amount is $max';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
