/// Centralised route name constants.
/// Always use these instead of raw string literals.
class AppRoutes {
  AppRoutes._();

  static const String splash        = '/';
  static const String onboarding    = '/onboarding';
  static const String login         = '/login';
  static const String register      = '/register';
  static const String verify        = '/verify';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword  = '/reset-password';
  static const String agreement     = '/agreement';
  static const String dashboard          = '/dashboard';

  // ── Create Project wizard ────────────────────────────────────────────────
  static const String createProjectAmount   = '/create-project/amount';
  static const String createProjectDetails  = '/create-project/details';
  static const String createProjectBorrowing = '/create-project/borrowing';
  static const String createProjectReview   = '/create-project/review';
  static const String createProjectSuccess  = '/create-project/success';

  // ── Profile sub-routes ───────────────────────────────────────────────────
  static const String editProfile        = '/profile/edit';
  static const String paymentMethods     = '/profile/payment-methods';
  static const String addCard            = '/profile/payment-methods/add-card';
  static const String cardDetail         = '/profile/payment-methods/detail';
  static const String transactionHistory = '/profile/transaction-history';
  static const String keyGuidelines      = '/profile/key-guidelines';
}
