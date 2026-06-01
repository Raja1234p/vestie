/// Stripe client configuration (flutter_stripe).
///
/// **Publishable key** (`pk_…`) is safe in the mobile app.
/// **Secret key** (`sk_…`) must ONLY live on the Vestie backend — never here.
abstract final class StripeConstants {
  /// Test publishable key (pair with backend `STRIPE_SECRET_KEY` for same account).
  static const String publishableKey =
      'pk_test_51TUaHSRzjwjo2AwntuvnVKuG0DRaIr0qwghxNsWuTAFHzYDBigiyx2SCo0pYWAf84Jw9jkhkC5TJEMGwYh1zo1Ez00iXdKe7iJ';

  /// Must match Android intent-filter and iOS `CFBundleURLSchemes`.
  static const String urlScheme = 'vestie';

  /// Required for redirect-based payment methods (PaymentSheet).
  static const String returnUrl = '$urlScheme://stripe-redirect';
}
