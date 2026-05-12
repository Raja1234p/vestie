import '../constants/app_strings.dart';
import 'person_name_input_formatter.dart';

/// All form validation lives here.
/// UI calls these methods and shows the returned error string.
/// Bloc/Cubit receives only already-validated data.
class ValidationUtils {
  ValidationUtils._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$',
  );

  // ── Email ──────────────────────────────────────────────────────────────────

  static String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errorEmailRequired;
    if (!_emailRegExp.hasMatch(v)) return AppStrings.errorEmailInvalid;
    return null;
  }

  // ── Password ───────────────────────────────────────────────────────────────

  static String? validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.errorPasswordRequired;
    if (v.length < 8) return AppStrings.errorPasswordWeak;
    if (!v.contains(RegExp(r'[a-zA-Z]'))) return AppStrings.errorPasswordWeak;
    if (!v.contains(RegExp(r'[0-9]'))) return AppStrings.errorPasswordWeak;
    return null;
  }

  /// Returns true when the password satisfies the strength rules (for inline indicator).
  static bool isPasswordStrong(String value) => validatePassword(value) == null;

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return AppStrings.errorPasswordRequired;
    if (value != password) return AppStrings.errorPasswordMismatch;
    return null;
  }

  /// Legal / display name — letters + internal spaces only (see [PersonNameInputFormatter]).
  static String? validateFullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errorNameRequired;
    if (!PersonNameInputFormatter.isValidTrimmed(v, allowSpaces: true)) {
      return AppStrings.errorPersonNameInvalidChars;
    }
    return null;
  }

  /// Profile `@handle` without digits or symbols (letters only, no spaces).
  static String? validateProfileUsernameHandle(String? value) {
    final t = (value ?? '').trim().replaceFirst(RegExp(r'^@+'), '');
    if (t.isEmpty) return AppStrings.errUsernameRequired;
    if (!PersonNameInputFormatter.isValidTrimmed(t, allowSpaces: false)) {
      return AppStrings.errorUsernameInvalidChars;
    }
    return null;
  }

  // ── OTP code ──────────────────────────────────────────────────────────────

  static String? validateOtpCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || v.length != 6 || int.tryParse(v) == null) {
      return AppStrings.errorOtpInvalid;
    }
    return null;
  }

  // ── Create Project ─────────────────────────────────────────────────────────

  static String? validateProjectName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errProjectNameRequired;
    if (v.length < 3) return AppStrings.errProjectNameShort;
    return null;
  }

  static String? validateProjectDescription(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errDescRequired;
    return null;
  }

  static String? validateProjectDeadline(DateTime? value) {
    if (value == null) return AppStrings.errDeadlineRequired;
    return null;
  }

  static String? validateBorrowLimit(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errBorrowLimitRequired;
    final n = int.tryParse(v);
    if (n == null || n <= 0) return AppStrings.errBorrowLimitInvalid;
    return null;
  }

  static String? validateRepaymentWindow(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errWindowRequired;
    final n = int.tryParse(v);
    if (n == null || n <= 0) return AppStrings.errWindowInvalid;
    return null;
  }

  /// Borrowing wizard: APR-style interest (e.g. `5` or `5%`).
  static String? validateAnnualRoiPercent(String? value) {
    final v = value?.trim().replaceAll('%', '') ?? '';
    if (v.isEmpty) return AppStrings.errAnnualRoiRequired;
    final n = double.tryParse(v);
    if (n == null || n < 0 || n > 100) {
      return AppStrings.errAnnualRoiInvalid;
    }
    return null;
  }

  /// Empty is valid; if filled, must be a plausible annual % (create-project ROI optional step).
  static String? validateOptionalAnnualRoiPercent(String? value) {
    final v = value?.trim().replaceAll('%', '') ?? '';
    if (v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null || n < 0 || n > 100) {
      return AppStrings.errAnnualRoiInvalid;
    }
    return null;
  }

  /// Repayment period measured in whole months (`6` meaning six months).
  static String? validateRepaymentMonths(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return AppStrings.errRepaymentMonthsRequired;
    final n = int.tryParse(raw);
    if (n == null || n < 1 || n > 120) {
      return AppStrings.errRepaymentMonthsInvalid;
    }
    return null;
  }

  /// Vacation/Emergency borrow step — whole days (maps to API `repaymentWindowDays`).
  static String? validateRepaymentDays(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return AppStrings.errRepaymentDaysRequired;
    final n = int.tryParse(raw);
    if (n == null || n < 1 || n > 3650) {
      return AppStrings.errRepaymentDaysInvalid;
    }
    return null;
  }

  static String? validatePenalty(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errPenaltyRequired;
    final n = double.tryParse(v);
    if (n == null || n < 0 || n > 100) return AppStrings.errPenaltyInvalid;
    return null;
  }

  // ── Payment Card ────────────────────────────────────────────────────────────

  static String? validateCardHolderName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errCardHolderRequired;
    if (!PersonNameInputFormatter.isValidTrimmed(v, allowSpaces: true)) {
      return AppStrings.errorPersonNameInvalidChars;
    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return AppStrings.errCardNumberRequired;
    if (digits.length != 16) return AppStrings.errCardNumberInvalid;
    return null;
  }

  static String? validateCardExpiry(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return AppStrings.errExpiryRequired;

    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(raw);
    if (match == null) return AppStrings.errExpiryInvalid;

    final month = int.tryParse(match.group(1)!);
    final yearTwoDigit = int.tryParse(match.group(2)!);
    if (month == null || yearTwoDigit == null || month < 1 || month > 12) {
      return AppStrings.errExpiryInvalid;
    }

    final now = DateTime.now();
    final fullYear = 2000 + yearTwoDigit;
    final expiryMonthStart = DateTime(fullYear, month);
    final currentMonthStart = DateTime(now.year, now.month);
    if (expiryMonthStart.isBefore(currentMonthStart)) {
      return AppStrings.errExpiryPast;
    }

    return null;
  }

  static String? validateCardCvv(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return AppStrings.errCvvRequired;
    if (digits.length < 3 || digits.length > 4) return AppStrings.errCvvInvalid;
    return null;
  }

  // ── Announcement ───────────────────────────────────────────────────────────

  static String? validateAnnouncementHeading(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errAnnouncementHeadingRequired;
    if (v.length < 3) return AppStrings.errAnnouncementHeadingShort;
    return null;
  }

  static String? validateAnnouncementContent(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errAnnouncementContentRequired;
    if (v.length < 5) return AppStrings.errAnnouncementContentShort;
    return null;
  }
}
