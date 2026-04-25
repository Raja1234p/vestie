/// Key constants for SecureStorage and SharedPreferences.
/// Never use raw string keys — always reference this class.
class StorageKeys {
  StorageKeys._();

  // ── Secure Storage (tokens — sensitive) ───────────────────────────────────
  static const String accessToken  = 'access_token';
  static const String refreshToken = 'refresh_token';

  // ── SharedPreferences (non-sensitive) ─────────────────────────────────────
  static const String isLoggedIn           = 'is_logged_in';
  static const String hasSeenOnboarding    = 'has_seen_onboarding';
  static const String disclaimerAccepted   = 'disclaimer_accepted';
}
