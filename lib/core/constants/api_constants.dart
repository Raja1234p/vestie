/// Centralised REST API endpoint constants.
/// All paths are relative to [baseUrl].
/// Never use raw string URLs anywhere in the app — always reference this class.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://192.168.18.108:7047';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String register       = '/api/v1/auth/register';
  static const String verifyEmail    = '/api/v1/auth/verify-email';
  static const String resendCode     = '/api/v1/auth/resend-code';
  static const String login          = '/api/v1/auth/login';
  static const String refreshToken   = '/api/v1/auth/refresh';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String resetPassword  = '/api/v1/auth/reset-password';
  static const String googleLogin    = '/api/v1/google';
  static const String appleLogin     = '/api/v1/auth/apple';
  static const String logout         = '/api/v1/auth/logout';

  // ── User ─────────────────────────────────────────────────────────────────
  static const String me              = '/api/v1/users/me';
  static const String riskDisclaimer  = '/api/v1/users/me/risk-disclaimer';

  static const String googleServerClientId = '531408349211-pfs5okgjus8t8iecl9arrt782mo4ppob.apps.googleusercontent.com';

  // ── Static values ────────────────────────────────────────────────────────
  static const String disclaimerVersion = '1.0';
  static const String defaultDeviceName = 'Flutter';
  static const String defaultIpAddress  = '0.0.0.0';
}
