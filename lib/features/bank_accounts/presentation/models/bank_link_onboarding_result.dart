/// Result of the bank link browser onboarding route (`context.pop` value).
enum BankLinkOnboardingResult {
  /// Account already linked (API had no onboarding URL).
  linked,

  /// Stripe redirected to the complete URL — verify accounts on the screen.
  completed,

  incomplete,
  canceled,
}
