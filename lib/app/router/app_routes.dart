/// Centralised route name constants.
/// Always use these instead of raw string literals.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';

  /// Shared project invite — `vestie.app/join/{inviteCode}`.
  static const String projectInvitationPath = '/join/:inviteCode';
  static String projectInvitation(String inviteCode) => '/join/$inviteCode';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verify = '/verify';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String passwordUpdatedSuccess = '/password-updated-success';
  static const String agreement = '/agreement';
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';

  // ── Create Project wizard ────────────────────────────────────────────────
  static const String createProjectAmount = '/create-project/amount';
  static const String createProjectDetails = '/create-project/details';
  static const String createProjectSavingSettings =
      '/create-project/saving-settings';
  static const String createProjectFundsBorrowing =
      '/create-project/funds-borrowing';
  static const String createProjectInvestmentSettings =
      '/create-project/investment-settings';
  static const String createProjectReview = '/create-project/review';
  static const String createProjectSuccess = '/create-project/success';

  /// Vacation / Emergency member-view storyboard (local mocks, Desktop images).
  static const String createProjectVacationSetup =
      '/create-project/member-flow/vacation/setup';
  static const String createProjectEmergencySetup =
      '/create-project/member-flow/emergency/setup';

  /// Member Vacation/Emergency flow → summary sheet (storyboard-aligned names).
  static const String createProjectFundSummary =
      '/create-project/member-flow/summary';
  static const String createProjectFundDetail =
      '/create-project/member-flow/detail';
  static const String createProjectFundContributionProgress =
      '/create-project/member-flow/contribution-progress';
  static const String createProjectFundStatus =
      '/create-project/member-flow/status';

  // ── Profile sub-routes ───────────────────────────────────────────────────
  static const String editProfile = '/profile/edit';
  static const String paymentMethods = '/profile/payment-methods';
  static const String myAccounts = '/profile/my-accounts';
  static const String cardDetail = '/profile/payment-methods/detail';
  static const String transactionHistory = '/profile/transaction-history';
  static const String completedProjects = '/profile/completed-projects';
  static const String completedProjectDetail =
      '/profile/completed-projects/detail';
  static const String keyGuidelines = '/profile/key-guidelines';

  // ── Wallet Transaction Routing ───────────────────────────────────────────
  static const String transactionAmount = '/wallet/transaction-amount';
  static const String withdrawMethod = '/wallet/withdraw-method';
  static const String walletRecentActivity = '/wallet/recent-activity';
  static const String selectPaymentMethod = '/wallet/select-payment-method';
  static const String selectBankAccount = '/wallet/select-bank-account';
  static const String kycOnboarding = '/kyc/onboarding';
  static const String bankLinkOnboarding = '/bank/link-onboarding';
  static const String transactionConfirmation =
      '/wallet/transaction-confirmation';
  static const String transactionSuccess = '/wallet/transaction-success';

  // ── Project Detail Routing ───────────────────────────────────────────────
  static const String projectDetail = '/project/detail';
  static const String contributeFlow = '/project/contribute';
  static const String contributePaymentPicker =
      '/project/contribute/payment-method';
  static const String borrowFlow = '/project/borrow';
  static const String investmentProjectDetail = '/project/investment-detail';
  static const String memberDetail = '/project/member-detail';
  static const String memberPenaltyAction = '/project/member-penalty-action';
  static const String createAnnouncement = '/project/create-announcement';

  /// Leader / co-leader storyboard hub (rows depend on primary vs co-leader).
  static const String leaderProjectSettings = '/project/leader-settings';
  static const String joinRequests = '/project/join-requests';
  static const String borrowRequests = '/project/borrow-requests';
  static const String groupMembers = '/project/group-members';
  static const String myBorrowRequest = '/project/my-borrow-request';
  static const String borrowRepayPaymentOptions =
      '/project/borrow-repay-payment-options';
  static const String borrowRepayConfirm = '/project/borrow-repay-confirm';
  static const String borrowRepaySuccess = '/project/borrow-repay-success';
  static const String projectFundsHistory = '/project/funds-history';
  static const String markProjectSuccessful = '/project/mark-successful';
  static const String stopContributions = '/project/stop-contributions';
  static const String votingWindow = '/project/voting-window';
  static const String leaderVoteStarted = '/project/leader-vote-started';
  static const String cancelProject = '/project/cancel';
  static const String projectCancelled = '/project/cancelled';

  // ── Member user flows (join + success vote) ────────────────────────────
  /// Public group — immediate join success (`AppSuccessScreen`).
  static const String projectJoinedSuccess = '/project/joined-success';

  static const String userStatusFlow = '/user/status-flow';
  static const String userSuccessVote = '/user/success-vote';
  static const String userVoteOutcome = '/user/vote-outcome';
  static const String leaderViewSuccessVotes =
      '/project/leader-view-success-votes';

  /// User investment journey (Vacation/Emergency style — mocks).
  static const String userInvestmentProjectDetail =
      '/user/investment/project-detail';
  static const String userInvestmentReturns = '/user/investment/my-returns';
  static const String leaderDistributeFunds =
      '/project/investment/distribute-funds';
  static const String leaderInvestmentDistribution =
      '/project/investment/distribution';
  static const String leaderInvestmentDistributionSuccess =
      '/project/investment/distribution-success';
  static const String userInvestmentFundsHistory =
      '/user/investment/funds-history';
  static const String leaveProjectWarning = '/project/leave-warning';

  /// @deprecated Use [leaveProjectWarning].
  static const String userInvestmentLeaveWarning = leaveProjectWarning;

  // ── VFF (Verified Friends & Family) ───────────────────────────────────────
  static const String userVffMain = '/user/vff';

  /// Hub “See all” on inbound VFF request rows (`user_vff_vff_requests_screen.dart`).
  static const String userVffVffRequestsAll = '/user/vff/requests-all';
  static const String userVffGroupInvitesAll = '/user/vff/group-invites-all';
  static const String userVffProfile = '/user/vff/profile';

  /// Accept / join success terminal (`user_vff_invites_sent_screen.dart`).
  static const String userVffInvitesSent = '/user/vff/invite-success';
}
