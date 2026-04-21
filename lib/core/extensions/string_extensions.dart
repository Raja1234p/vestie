import '../utils/validation_utils.dart';

extension StringExtensions on String {
  bool get isEmailValid => ValidationUtils.validateEmail(this) == null;
  bool get isPasswordValid => ValidationUtils.validatePassword(this) == null;

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}
