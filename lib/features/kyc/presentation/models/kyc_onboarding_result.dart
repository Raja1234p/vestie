/// Result of the in-app KYC browser onboarding route (`context.pop` value).
///
/// Stripe Connect Account Links: [return_url] only means the user left hosted
/// onboarding (finished, saved for later, or exited). Always check account
/// requirements via `GET /kyc/status` — never treat [return_url] alone as success.
enum KycOnboardingResult {
  /// `canWithdraw` — verified and payouts enabled.
  completed,

  /// No outstanding requirements; Stripe is reviewing (status pending).
  pendingReview,

  /// Returned from Stripe but requirements remain or onboarding not finished.
  incomplete,

  /// User closed the app screen (back) before a Stripe [return_url] redirect.
  canceled,

  /// Stripe rejected the connected account.
  rejected,
}
