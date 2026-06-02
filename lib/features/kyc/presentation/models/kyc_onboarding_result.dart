/// Result of the in-app KYC WebView route (`context.pop` value).
enum KycOnboardingResult {
  /// Stripe redirected to `returnUrl` and `GET /kyc/status` confirms withdraw-ready.
  completed,

  /// Stripe redirected to `returnUrl` but account is not verified yet (e.g. pending).
  pending,

  /// User left before a return redirect, or status could not be confirmed.
  canceled,
}
