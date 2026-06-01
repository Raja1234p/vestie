/// Key constants for SecureStorage and SharedPreferences.
/// Never use raw string keys — always reference this class.
class StorageKeys {
  StorageKeys._();

  // ── Secure Storage (tokens — sensitive) ───────────────────────────────────
  static const String accessToken  = 'access_token';
  static const String refreshToken = 'refresh_token';

  // ── SharedPreferences (non-sensitive) ─────────────────────────────────────
  static const String isLoggedIn           = 'is_logged_in';
  static const String userName             = 'user_name';
  static const String userUsername         = 'user_username';
  static const String userEmail            = 'user_email';
  static const String userPhotoUrl         = 'user_photo_url';
  static const String hasSeenOnboarding    = 'has_seen_onboarding';
  static const String disclaimerAccepted   = 'disclaimer_accepted';

  /// Last successful risk-disclaimer snapshot (non-sensitive; speeds cold start).
  static const String riskDisclaimerCachedAt = 'risk_disclaimer_cached_at';
  static const String riskDisclaimerVersion = 'risk_disclaimer_version';
  static const String riskDisclaimerGuidelinesJson = 'risk_disclaimer_guidelines_json';

  /// Last FCM token successfully registered with the API.
  static const String fcmDeviceToken = 'fcm_device_token';

  /// User dismissed the dashboard notification permission prompt.
  static const String notificationPermissionPromptDismissed =
      'notification_permission_prompt_dismissed';
}
