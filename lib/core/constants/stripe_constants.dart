/// Stripe client configuration (flutter_stripe).
///
/// **Publishable key** (`pk_…`) is safe in the mobile app.
/// **Secret key** (`sk_…`) must ONLY live on the Vestie backend — never here.
abstract final class StripeConstants {
  /// Live publishable key (pair with backend live `STRIPE_SECRET_KEY` for same account).
  /// Prefer `GET /stripe/config` when the API returns a key; this is the fallback.
  static const String publishableKey =
      'pk_live_51TUaHB2McZ6USmvdrvz1RBh86b5YfZSAjgOKMXuEMIs4P5KCzlD8phQhXrcMnncLBKkmWBdVCL02TDKwHyidgSbd007kjHEXip';

  /// Must match Android intent-filter and iOS `CFBundleURLSchemes`.
  static const String urlScheme = 'vestie';

  /// Required for redirect-based payment methods (PaymentSheet).
  static const String returnUrl = '$urlScheme://stripe-redirect';
}
