/// Centralised REST API endpoint constants.
/// All paths are relative to [baseUrl] (which includes `/api/v1`).
/// Never use raw string URLs anywhere in the app — always reference this class.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/api/v1';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String register       = '/auth/register';
  static const String verifyEmail    = '/auth/verify-email';
  static const String resendCode     = '/auth/resend-code';
  static const String login          = '/auth/login';
  static const String refreshToken   = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword  = '/auth/reset-password';
  static const String googleLogin    = '/auth/google';
  static const String appleLogin     = '/auth/apple';
  static const String logout         = '/auth/logout';

  // ── User ─────────────────────────────────────────────────────────────────
  static const String me              = '/users/me';
  static const String riskDisclaimer  = '/users/me/risk-disclaimer';

  // ── Projects ─────────────────────────────────────────────────────────────
  static const String projects = '/projects';

  /// `POST /projects/{id}/launch` — Draft → Active after create (Week 3/4).
  static String projectLaunch(String projectId) => '$projects/$projectId/launch';

  // ── Contributions ────────────────────────────────────────────────────────
  static const String contributions = '/contributions';

  static const String googleServerClientId = '531408349211-pfs5okgjus8t8iecl9arrt782mo4ppob.apps.googleusercontent.com';

  // ── Network ──────────────────────────────────────────────────────────────
  /// Max time for connect / send / receive on every API call (1 minute).
  static const Duration requestTimeout = Duration(minutes: 1);

  // ── Static values ────────────────────────────────────────────────────────
  static const String disclaimerVersion = '1.0';
  static const String defaultDeviceName = 'Flutter';
  static const String defaultIpAddress  = '0.0.0.0';
}
