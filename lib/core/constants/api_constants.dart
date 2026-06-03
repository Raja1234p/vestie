/// Centralised REST API endpoint constants.
/// All paths are relative to [baseUrl] (which includes `/api/v1`).
/// Never use raw string URLs anywhere in the app — always reference this class.
class ApiConstants {
  ApiConstants._();

  /// Week 4+ REST base (`/api/v1.0` per Vestie API documentation).
  static const String baseUrl = 'https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/api/v1';

  /// SignalR hubs live on the API host root (not under `/api/v1`).
  ///
  /// Azure staging:
  /// - `https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/hubs/projects`
  /// - `https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/hubs/wallet`
  static const String projectsHubPath = '/hubs/projects';
  static const String walletHubPath = '/hubs/wallet';

  /// Full hub URL for `signalr_netcore` (Bearer via `accessTokenFactory`).
  static String get projectsHubUrl => signalRHubUrl(projectsHubPath);

  static String get walletHubUrl => signalRHubUrl(walletHubPath);

  static String signalRHubUrl(String hubPath) {
    final rest = Uri.parse(baseUrl);
    return Uri(
      scheme: rest.scheme,
      host: rest.host,
      port: rest.hasPort ? rest.port : null,
      path: hubPath,
    ).toString();
  }

  /// API host root (no `/api/v1`) — used for Stripe Connect `return_url` / `refresh_url`.
  static Uri get apiOrigin {
    final rest = Uri.parse(baseUrl);
    return Uri(
      scheme: rest.scheme,
      host: rest.host,
      port: rest.hasPort ? rest.port : null,
    );
  }

  static String get stripeRedirectHost => apiOrigin.host;

  static String get kycReturnUrl =>
      apiOrigin.replace(path: '/kyc/complete').toString();

  static String get kycRefreshUrl =>
      apiOrigin.replace(path: '/kyc/refresh').toString();

  static String get bankReturnUrl =>
      apiOrigin.replace(path: '/bank/return').toString();

  static String get bankRefreshUrl =>
      apiOrigin.replace(path: '/bank/refresh').toString();

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
  static const String meSummary       = '/users/me/summary';
  static const String meProfilePicture = '/users/me/profile-picture';
  static const String riskDisclaimer  = '/users/me/risk-disclaimer';

  // ── VFF ──────────────────────────────────────────────────────────────────
  static const String userMeVffs = '/users/me/vffs';
  static String userMeVffProfile(String userId) => '/users/me/vffs/$userId';
  static String userVffPublicProfile(String userId) => '/users/$userId/vff-profile';
  static String userVffConnection(String userId) => '/users/$userId/vff';
  static const String userInboxReceived = '/users/me/inbox/received';
  static const String userInboxSent = '/users/me/inbox/sent';
  static String projectMemberVffRequest(String projectId, String userId) =>
      '$projects/$projectId/members/$userId/vff-requests';
  static String userVffRequestAccept(String requestId) =>
      '/users/me/vff-requests/$requestId/accept';
  static String userVffRequestDecline(String requestId) =>
      '/users/me/vff-requests/$requestId/decline';
  static String projectVffInvites(String projectId) =>
      '$projects/$projectId/vff-invites';
  static String projectVffInviteAccept(String projectId, String inviteId) =>
      '$projects/$projectId/vff-invites/$inviteId/accept';
  static String projectVffInviteDecline(String projectId, String inviteId) =>
      '$projects/$projectId/vff-invites/$inviteId/decline';
  static String projectJoinFromVff(String projectId) =>
      '$projects/$projectId/join-from-vff';

  // ── Projects ─────────────────────────────────────────────────────────────
  static const String projects = '/projects';

  /// `POST /projects/{id}/launch` — Draft → Active after create (Week 3/4).
  static String projectLaunch(String projectId) => '$projects/$projectId/launch';

  /// `GET /projects/{projectId}/members/{userId}/activity` — member profile metrics + ledger.
  static String projectMemberActivity(String projectId, String userId) =>
      '$projects/$projectId/members/$userId/activity';

  /// `POST /projects/{projectId}/members/{userId}/defaulted` — mark member defaulted.
  static String projectMemberDefaulted(String projectId, String userId) =>
      '$projects/$projectId/members/$userId/defaulted';

  /// `POST /projects/{projectId}/members/{userId}/remove-non-repayment`
  static String projectMemberRemoveNonRepayment(String projectId, String userId) =>
      '$projects/$projectId/members/$userId/remove-non-repayment';

  /// `POST` assign / `DELETE` remove — `/projects/{projectId}/members/{userId}/co-leader`
  static String projectMemberCoLeader(String projectId, String userId) =>
      '$projects/$projectId/members/$userId/co-leader';

  // ── Contributions (legacy paths — prefer [projectContributions]) ─────────
  static const String contributions = '/contributions';

  static String projectContributions(String projectId) =>
      '$projects/$projectId/contributions';

  static String projectPot(String projectId) => '$projects/$projectId/pot';

  // ── Wallet ───────────────────────────────────────────────────────────────
  static const String wallet = '/wallet';

  static const String walletDepositIntent = '/wallet/deposit/intent';

  static String walletDepositStatus(String paymentIntentId) =>
      '/wallet/deposit/$paymentIntentId/status';

  static const String walletDepositSimulated = '/wallet/deposit';

  static const String walletWithdrawalsPreview = '/wallet/withdrawals/preview';

  static const String walletWithdrawals = '/wallet/withdrawals';

  static String walletWithdrawalStatus(String withdrawalId) =>
      '/wallet/withdrawals/$withdrawalId';

  // ── KYC & bank ───────────────────────────────────────────────────────────
  static const String kycStart = '/kyc/start';

  static const String kycStatus = '/kyc/status';

  static const String bankAccounts = '/bank-accounts';

  static String bankAccount(String bankAccountId) =>
      '/bank-accounts/$bankAccountId';

  // ── Stripe (Week 5) ──────────────────────────────────────────────────────
  static const String stripeConfig = '/stripe/config';

  static const String stripeConnectAccount = '/stripe/connect/account';

  static String stripeConnectOnboardingLink(String accountId) =>
      '/stripe/connect/accounts/$accountId/onboarding-link';

  // ── Payment methods ──────────────────────────────────────────────────────
  static const String paymentMethods = '/payment-methods';

  static const String paymentMethodsSetupIntent =
      '/payment-methods/setup-intent';

  static String paymentMethod(String paymentMethodId) =>
      '/payment-methods/$paymentMethodId';

  static String paymentMethodPrimary(String paymentMethodId) =>
      '/payment-methods/$paymentMethodId/primary';

  // ── Notifications ────────────────────────────────────────────────────────
  static const String notificationsDeviceToken = '/notifications/device-token';

  static const String notifications = '/notifications';

  static const String notificationsMarkRead = '/notifications/mark-read';

  static String projectAnnouncements(String projectId) =>
      '$projects/$projectId/announcements';

  static String projectAnnouncement(
    String projectId,
    String announcementId,
  ) =>
      '$projects/$projectId/announcements/$announcementId';

  static const String googleServerClientId = '531408349211-pfs5okgjus8t8iecl9arrt782mo4ppob.apps.googleusercontent.com';

  // ── Network ──────────────────────────────────────────────────────────────
  /// Max time for connect / send / receive on every API call (1 minute).
  static const Duration requestTimeout = Duration(minutes: 1);

  // ── Static values ────────────────────────────────────────────────────────
  static const String disclaimerVersion = '1.0';
  static const String defaultDeviceName = 'Flutter';
  static const String defaultIpAddress  = '0.0.0.0';
}
