import 'package:vestie/core/utils/formatters.dart';

class AppStrings {
  AppStrings._();

  // App Meta
  static const String appName = 'Vestie';

  // General
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'No internet connection. Please check your network.';
  static const String errorLaunchProject =
      'Project was saved but could not be launched. Please try again.';
  static const String errorUpdateProject =
      'Could not update project. Please try again.';
  static const String projectUpdatedSuccess = 'Project updated successfully.';
  static const String errorForbidden =
      'You do not have permission to view this.';
  static const String projectNotFound =
      'Project not found or is no longer available.';
  static const String joinRequestsEmpty = 'No pending join requests.';
  static const String joinRequestsEmptyTitle = 'No Join Request';
  static const String errorUnauthorized =
      'Session expired. Please log in again.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorTimeout = 'Request timed out. Please try again.';

  // ── Error Dialog ──────────────────────────────────────────────────────────
  static const String errorDialogTitle = 'Something went wrong';

  /// Shown when there is no HTTP response (offline / DNS / unreachable).
  static const String errorDialogOfflineTitle =
      'Please check your internet connection and try again.';
  static const String btnRetry = 'Try Again';
  static const String btnDismiss = 'Dismiss';
  static const String noInternet = 'No internet connection detected.';
  static const String errorGoogleSignInFailed =
      'Could not sign in with Google. Please try again.';
  static const String errorGoogleSignInNoToken =
      'Could not complete Google sign-in. Please try again.';

  // Auth Flow
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue where you left off.';
  static const String registerTitle = 'Create your account';
  static const String registerSubtitle =
      'Set up your account to manage your money securely.';
  static const String verifyTitle = 'Verify your account';
  static const String verifySubtitle = 'Enter the code sent to your email.';

  // Field Labels
  static const String labelEmail = 'Email';
  static const String labelPassword = 'Password';
  static const String labelFullName = 'Full name';
  static const String labelConfirmPassword = 'Confirm Password';
  static const String labelVerifyCode = 'Verification code';

  // Placeholders
  static const String hintEmail = 'you@example.com';
  static const String hintPassword = 'Enter password';
  static const String hintCreatePassword = 'Create a strong password';
  static const String hintFullName = 'As per your official ID';
  static const String hintConfirmPassword = 'Re-enter your password';
  static const String hintVerifyCode = 'Enter 6-digit code';

  // Buttons & Links
  static const String btnContinue = 'Continue';
  static const String btnVerify = 'Verify';
  static const String btnCreateAccount = 'Create Account';
  static const String btnGoogle = 'Continue with Google';
  static const String btnApple = 'Continue with Apple';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account? ";
  static const String signupLink = 'Sign up';
  static const String hasAccount = 'Already have an account? ';
  static const String loginLink = 'Log In';
  static const String didntReceive = "Didn't receive it? ";
  static const String resendCode = 'Resend code';
  static const String orDivider = 'or';

  // Validation hints
  static const String passwordHint = '8+ characters with letters and numbers';

  // Forgot Password
  static const String forgotTitle = 'Forgot your password?';
  static const String forgotSubtitle =
      'Enter your email to receive a verification code';
  static const String labelEmailAddress = 'Email address';
  static const String hintRegisteredEmail = 'Enter your registered email';
  static const String btnSendResetEmail = 'Send Reset Email';
  static const String forgotSuccessMsg =
      'Reset link sent! Please check your email.';

  // Reset Password
  static const String resetPasswordTitle = 'Set a new password';
  static const String resetPasswordSubtitle =
      'Choose a strong password for your account.';
  static const String labelNewPassword = 'New password';
  static const String hintNewPassword = 'Enter new password';
  static const String labelConfirmNewPass = 'Confirm new password';
  static const String hintConfirmNewPass = 'Re-enter new password';
  static const String btnResetPassword = 'Reset password';
  static const String resetSuccessMsg = 'Password reset successfully!';
  static const String passwordUpdatedTitle = 'Password Updated!';
  static const String passwordUpdatedSubtitle =
      'Your password has been changed successfully. You can now log in with your new password.';
  static const String btnGoBack = 'Go Back';
  static const String btnBackToLogin = 'Back to Login';

  // Agreement Screen
  static const String agreementTitle = 'Before You Continue';
  static const String agreementSubtitle =
      'Using Vestie means you accept all of the following guidelines.';
  static const String agreementCheckbox =
      'I have read and accept these guidelines';
  static const List<String> agreementItems = [
    'Users join pots and contribute entirely at their own risk',
    'Vestie does not guarantee the safety or return of any funds',
    'Only send money to people you personally know and trust',
    'Repayment terms and penalties are set by group leaders, not Vestie',
    'All contributions processed through Vestie are final and non-refundable',
  ];

  // State
  static const String loading = 'Loading...';
  static const String loadingResendOtp = 'Sending code...';
  static const String otpSentSuccessToast = 'OTP Send Successfully';
  static const String emptyData = 'No data available';

  // ── Social Auth ────────────────────────────────────────────────────────────
  static const String socialComingSoon = 'Social sign-in coming soon.';

  // ── Validation Errors ──────────────────────────────────────────────────────
  static const String errorEmailRequired = 'Email is required.';
  static const String errorEmailInvalid = 'Enter a valid email address.';
  static const String errorPasswordRequired = 'Password is required.';
  static const String errorPasswordWeak =
      'Use 8+ characters with uppercase, lowercase, a number, and a symbol.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorNameRequired = 'Full name is required.';
  static const String errorPersonNameInvalidChars =
      'Use letters and spaces only. Numbers and symbols are not allowed.';
  static const String errUsernameRequired = 'Username is required.';
  static const String errUsernameTooLong =
      'Username must be 50 characters or fewer.';
  static const String errorUsernameInvalidChars =
      'Username cannot contain spaces.';
  static const String errorOtpInvalid = 'Please enter a valid 6-digit code.';

  // Onboarding Flow
  static const String onboarding1Title = 'Track everything\nin one place';
  static const String onboarding1Subtitle =
      'See your total contributions, active pots, and progress toward shared goals—all in a single view.';
  static const String onboarding2Title = 'Contribute in\nseconds';
  static const String onboarding2Subtitle =
      'Add money to your group pot easily. Stay consistent and move closer to your goal together.';
  static const String onboarding3Title = 'Borrow with\napproval';
  static const String onboarding3Subtitle =
      'Request funds when needed. Your group reviews and votes, keeping everything fair and transparent.';
  static const String onboardingContinue = 'Continue';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboardingSkip = 'Skip';

  // ── Bottom Navigation ────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navSearch = 'Search';
  static const String navAdd = 'Add';
  static const String navWallet = 'Wallet';
  static const String navProfile = 'Profile';

  // ── Home Screen ──────────────────────────────────────────────────────────
  static const String totalContributed = 'Total Contributed';
  static const String myProjects = 'My Projects';
  static const String joinedProjects = 'Joined Projects';
  static const String homeEmptyTitle = 'Start saving together';
  static const String homeEmptySubtitle =
      'Create a pot, invite your people,\nreach your goal.';
  static const String btnCreateProject = 'Create a project';
  static const String btnView = 'View';
  static const String btnJoin = 'Join';
  static const String btnRequestToJoin = 'Request to join';
  static const String btnSendRequest = 'Send Request';
  static const String projectJoinRequestSubmitted = 'Request Submitted';
  static const String projectInvitationJoinProject = 'Join Project';
  static const String projectInvitationRequestToJoin = 'Request to Join';
  static const String projectInvitationExpectedRoi = 'Expected ROI';
  static const String projectInvitationMaybeLater = 'Maybe Later';
  static const String projectInvitationProjectType = 'Project Type';
  static const String projectInvitationMembers = 'Members';
  static const String projectInvitationContributions = 'Contributions';
  static const String projectInvitationDescription = 'Description';
  static const String projectInvitationExpired =
      'This invite link has expired.';
  static const String projectInvitationNotJoinable =
      'This project is not accepting new members right now.';
  static String projectInvitationMembersCount(int count) =>
      '$count ${count == 1 ? userVffBadgeMember : userVffMembersCountSuffix}';
  static const String projectJoinedSuccessTitle = 'Project Joined';
  static const String projectJoinRequestSentTitle = 'Request Sent';
  static const String projectJoinRequestSentSubtitle =
      "Your request has been sent to the project leader. You'll be notified once your request is approved.";
  static String projectJoinedWelcomeSubtitle(String projectName) =>
      'Welcome to $projectName';
  static const String btnOpenProject = 'Open Project';
  static const String labelGoal = 'Goal';
  static const String labelRaised = 'Raised';
  static const String labelInvested = 'Invested';
  static const String labelTotal = 'Total';
  static const String labelEndsIn = 'Ends in';
  static const String labelRoiColon = 'ROI:';
  static const String projectEndEnded = 'Ended';
  static const String projectEndToday = 'Ends today';
  static const String projectEndLessThanOneDay = 'Less than a day';

  /// Shown when deadline is under one minute away (ISO deadline path).
  static const String projectEndLessThanOneMinute = 'Less than a minute';
  static const String projectEndOneDay = '1 day';
  static const String projectEndOneMonth = '1 month';

  static String projectEndMonthsOnly(int months) =>
      months == 1 ? projectEndOneMonth : '$months months';

  static String projectEndDaysOnly(int days) =>
      days == 1 ? projectEndOneDay : '$days days';

  static const String projectEndOneMonthOneDay = '1 month, 1 day';

  static String projectEndOneMonthDays(int days) =>
      '1 month, ${projectEndDaysOnly(days)}';

  static String projectEndMonthsOneDay(int months) =>
      '${projectEndMonthsOnly(months)}, 1 day';

  static String projectEndMonthsDays(int months, int days) =>
      '${projectEndMonthsOnly(months)}, ${projectEndDaysOnly(days)}';

  static const String statusOnGoing = 'On Going';
  static const String statusCompleted = 'Completed';

  // ── Discover Screen ──────────────────────────────────────────────────────
  static const String discoverTitle = 'Discover';
  static const String discoverSearchHint =
      'Search projects, categories, members';
  static const String discoverEmptyTitle = 'No Projects';
  static const String discoverEmptySubtitle =
      'No projects are available to discover.';
  static const String discoverNoMatchingTitle = 'No matching projects';
  static const String discoverNoMatchingSubtitle =
      'Try adjusting your search or filters.';
  static const String filterAll = 'All';
  static const String filterVacations = 'Vacations';
  static const String filterEmergency = 'Emergency Fund';
  static const String filterInvestments = 'Investment';
  static const String createProjectMemberWalkthroughLink =
      'Vacation & Emergency fund · UI walkthrough';

  // ── Member Vacation/Emergency flow picker (pure UI mocks)
  static const String createProjectMemberWalkthroughSheetTitle =
      'Choose fund type (mock flow)';
  static const String createProjectMemberWalkthroughVacationTitle =
      'Vacation Fund';
  static const String createProjectMemberWalkthroughVacationSubtitle =
      'Setup → Summary → Detail → Contributions → Payment status';
  static const String createProjectMemberWalkthroughEmergencyTitle =
      'Emergency Fund';
  static const String createProjectMemberWalkthroughEmergencySubtitle =
      'Same navigation pattern with emergency demo values';

  static const String createProjectVacationFundTitle = 'Vacation Fund';
  static const String createProjectEmergencyFundTitle = 'Emergency Fund';
  static const String createProjectSummaryTitle = 'Project summary';
  static const String createSummarySubtitleVacation =
      'Review vacation goal and timeline — no server call yet.';
  static const String createSummarySubtitleEmergency =
      'Review emergency buffer goal — no server call yet.';
  static const String summaryDesignNotePlaceholder =
      'Design note: screenshots can be dropped into Desktop/images/';
  static const String summaryPlaceholderDescription =
      'No description added — placeholder copy for empty stages.';
  static const String summaryLabelGoal = 'Goal';
  static const String summaryLabelStarts = 'Starts';
  static const String summaryLabelEnds = 'Ends';
  static const String summaryLabelAbout = 'About';

  static const String pickDatePlaceholder = 'Tap to choose a date';

  static const String labelGoalAmountUsd = 'Goal Amount';
  static const String hintGoalAmountUsd = 'e.g. 10750 or 1450';
  static const String labelStartDate = 'Start date';
  static const String labelEndDate = 'End date';
  static const String hintVacationEmergencyProjectName =
      'Rainy getaway pot · buffer fund';

  static const String detailCardProjectLeader = 'Project leader';
  static const String detailCardDescription = 'Description';
  static const String detailCardTimeline = 'Timeline';
  static const String detailMembersStripTitle = 'Members';
  static const String detailMembersViewAll = 'View all';
  static const String placeholderLeaderDisplayName = 'Taylor (mock)';
  static const String placeholderLeaderSubtitle =
      'You are previewing member view';

  static String timelineStartsOn(String formatted) => 'Starts on $formatted';
  static String timelineEndsOn(String formatted) => 'Ends on $formatted';

  static const String contributionProgressTitle = 'Contribution progress';
  static const String contributionProgressSubtitle = 'toward goal';
  static const String contributionHistoryTitle = 'Contribution history';
  static const String contributionProgressDemoHint =
      'Actions below only navigate — no checkout or APIs yet.';
  static const String btnSimulatePaymentSuccess = 'Simulate successful payment';
  static const String btnSimulatePaymentFailure = 'Simulate failed payment';

  static const String transactionStatusSuccessTitle = 'Payment successful';
  static const String transactionStatusSuccessSubtitle =
      'Funds would move to this pot once the backend is wired.';
  static const String transactionStatusFailureTitle = 'Transaction failed';
  static const String transactionStatusFailureSubtitle =
      'Mock feedback for the Emergency flow — try again or cancel.';

  static const String validationProjectNameRequired =
      'Project name is required.';
  static const String validationGoalUsdInvalid =
      'Enter a goal amount greater than zero.';
  static const String validationStartDateRequired = 'Please pick a start date.';
  static const String validationEndAfterStartRequired =
      'End date must be after start date.';

  // ── User investment flow (Vacation/Emergency — UI mocks)
  static const String userInvestmentDiscoverEntry =
      'User investment · UI walkthrough';
  static const String userInvestmentChooserTitle = 'Investment flow preview';
  static const String userInvestmentChooserWithMembers =
      'Active members (storyboard)';
  static const String userInvestmentChooserEmptyMembers = 'Empty members state';
  static const String userInvestmentGoalMonthly = 'Goal \$2,700 / Month';
  static String userInvestmentGoalMonthlyAmount(String amountUsd) =>
      'Goal \$$amountUsd / Month';
  static String userInvestmentRaisedAmount(String amountUsd) =>
      'Raised \$$amountUsd';
  static String userInvestmentNextContribution(String formattedDate) =>
      'My Next Contribution • $formattedDate';
  static const String userInvestmentMembersEmpty = 'No Members';
  static const String userInvestmentMembersTitle = 'Members';
  static const String userInvestmentMemberActive = 'Active';
  static const String btnViewMyReturns = 'View My Returns';
  static const String userInvestmentReturnsTitle = 'My Investment Returns';
  static const String userInvestmentMyContributionLabel = 'My Contribution';
  static const String userInvestmentReceivedSoFarLabel = 'Received so far';
  static const String userInvestmentPaymentHistoryTitle = 'Payment History';
  static const String investmentLeaderDistributionLabel = 'Leader distribution';
  static const String investmentDistributionAmountLabel = 'Distribution Amount';
  static const String investmentTotalDistributionsLabel = 'Total Distributions';
  static const String investmentReceivedShareLabel = 'Received share';
  static const String investmentMyShareLabel = 'My share';
  static String investmentDistributionTitle(int number) =>
      'Distribution #$number';
  static const String btnInvestmentReturns = 'Investment Returns';
  static const String btnDistributeFunds = 'Distribute Funds';
  static const String distributeAmountPrompt =
      'How much you want to distribute?';
  static const String investmentDistributionScreenTitle = 'Distribution';
  static const String investmentDistributingLabel = 'Distributing';
  static String investmentDistributingToMembers(int count) =>
      'to all $count members';
  static String investmentRemainingToDistribute(String formattedAmount) =>
      'Remaining to distribute: $formattedAmount';
  static const String btnConfirmAndDistribute = 'Confirm & Distribute';
  static const String fundsDistributedSuccessTitle = 'Funds Distributed!';
  static String fundsDistributedSentToMembers(int count) =>
      'sent to $count members';
  static const String investmentDistributionColMember = 'MEMBER';
  static const String investmentDistributionColContributed = 'CONTRIBUTED';
  static const String investmentDistributionColShare = 'SHARE';
  static const String investmentDistributionColReceives = 'RECEIVES';
  static const String distributeFundsActionPending =
      'Distribute funds flow coming soon.';
  static const String btnPreviewCompletedInvestment =
      'Preview completed investment UI';
  static const String userInvestmentInvestedAmountLabel = 'Invested Amount';
  static const String userInvestmentReturnsHistoryTitle = 'Returns History';
  static const String userInvestmentFundsHistoryTitle = 'Project Funds History';
  static const String userInvestmentTotalFundsLabel = 'Total Project Funds';
  static String userInvestmentMembersModalTitle(int count) =>
      'Project Members ($count)';
  static const String userInvestmentShareRowHint =
      'Share this pot with your circle.';
  static const String userInvestmentMenuFundsHistory = 'Project Funds History';
  static const String userInvestmentMenuViewMembers = 'View Members';
  static const String userInvestmentMenuLeave = 'Leave Project';
  static const String userLeaveStayHere = 'Stay Here';
  static const String userLeaveConfirmYes = 'Yes';
  static const String leaveProjectWarningTitle = 'Leave Project';
  static const String leaveProjectWarningBody =
      'You\'re leaving this project and will not receive any amount back '
      'that you\'ve deposit in this project.';
  static const String leaveProjectConfirmDialogBody =
      'Are you sure you want to leave this project?';
  static const String leaveProjectSuccessTitle =
      'You\'re no longer a part of this project';
  static const String leaveProjectSuccessBody =
      'You\'ve left this project and cant contribute anymore';

  // ── VFF (Verified Friends & Family — UI model, ready for API wiring)
  static const String userVffHubTitle = 'My VFFs & Requests';
  static const String userVffTabMyVffs = 'My VFFs';
  static const String userVffTabRequests = 'Requests';
  static const String userVffRequestsReceived = 'Received';
  static const String userVffRequestsSent = 'Sent';
  static const String userVffSentJoinRequestsSection = 'Join Requests';
  static const String userVffEmptyMyVffs = 'You don\'t have any VFFs yet.';
  static const String inviteMembersAllVffsInProject =
      'All of your VFFs are already in this group.';
  static const String userVffEmptyRequests = 'No Pending Requests';
  static const String userVffSectionMyVffs = 'My VFFs';
  static const String userVffSectionSentVffRequests = 'Sent VFF Requests';
  static const String userVffSectionVffRequests = 'VFF Requests';
  static const String userVffSectionGroupInvites = 'Group Invitations';
  static const String userVffSeeAllRequestsLink = 'See All Requests';
  static const String userVffSeeAllVffRequestsLink = userVffSeeAllRequestsLink;
  static const String userVffSeeAllGroupInvitesLink = userVffSeeAllRequestsLink;
  static const String userVffViaProject = 'via';
  static const String userVffInvitedBy = 'Invited by';
  static const String btnAccept = 'Accept';
  static const String btnDecline = 'Decline';
  static const String userVffJoined = 'Joined';
  static const String userVffRequestToJoin = 'Request to Join';
  static String userVffMutualProjects(int n) => '$n mutual projects';
  static const String userVffStatusRequestSentSmall = 'Request Sent';
  static const String userVffVffRequestsListTitle = 'VFF Requests';
  static const String userVffGroupInvitationsTitle = 'Project Invitations';

  /// Profile
  static const String userVffBadgeMember = 'Member';
  static const String userVffBadgeVff = 'VFF Badge';
  static const String btnAddFriend = 'Send VFF Request';
  static const String projectMemberLeaderBadge = 'Leader';
  static const String projectMemberCoLeaderBadge = 'Co Leader';
  static const String userVffProfileTitleSuffix = ' Profile';
  static const String userVffContributed = 'Contributed';
  static const String userVffContributions = 'Contributions';
  static const String userVffContribution = 'Contribution';
  static const String userVffProjectsMetric = 'Projects';
  static const String btnSendVffRequest = 'Send VFF Request';
  static const String btnVffRequestSent = 'VFF Request Sent';
  static String userVffTxTitle(String fundNamePortion) =>
      'Contribution: $fundNamePortion';

  /// Remove VFF dialog
  static String userVffRemoveTitle(String username) =>
      'Are you sure you want to remove $username?';
  static const String userVffRemoveBody =
      'You will no longer be able to view their joined projects.';
  static const String btnYesRemoveVff = 'Yes, Remove VFF';

  /// Following menu
  static const String userVffFollowing = 'Following';

  /// Connected VFF profile footer dropdown label (Figma).
  static const String userVffFooterMenuLabel = 'VFF';
  static const String userVffMenuRemoveConnection = 'Remove VFF';

  /// Invite success (headline + sub copy + bold project line in UI)
  static const String userVffInviteSuccessTitle = 'Invites Sent!';
  static String userVffInviteSubtitle(int inviteCount) {
    if (inviteCount <= 1) return '1 VFF has been invited to';
    return '$inviteCount VFFs have been invited to';
  }

  /// Profile metrics (trio variant)
  static const String userVffContributionLabelSingular = 'Contribution';
  static const String userVffContributionsPlural = 'Contributions';
  static const String userVffProjectsLabel = 'Projects';

  /// Joined projects strip
  static const String userVffMembersCountSuffix = 'Members';

  // ── Notifications ───────────────────────────────────────────────────────
  static const String notificationsTitle = 'Notifications';
  static const String notificationEmptyTitle = 'No Notification Yet';
  static const String notificationEmptySubtitle =
      "You'll see notification when they are available";
  // Sample list (debug / design preview) — [notification_samples]
  static const String notificationTime3min = '3 min ago';
  static const String notificationTime12min = '12 min ago';
  static const String notificationTime1hr = '1 hr ago';
  static const String notificationTime2hr = '2 hr ago';
  static const String notificationTimeYesterday = 'Yesterday';
  static const String notificationTime2days = '2 days ago';
  static const String notificationSample1Title = 'Deposit Successful';
  static const String notificationSample1Body =
      'Your wallet has been topped up.';
  static const String notificationSample2Title = 'Project Created';
  static const String notificationSample2Body =
      'Your new project is live. Start inviting members.';
  static const String notificationSample3Title = 'Contribution Sent';
  static const String notificationSample3Body =
      'Your payment was received by the pot.';
  static const String notificationSample4Title = 'Member Overdue';
  static const String notificationSample4Body =
      'Alex has an unpaid borrow in your group.';
  static const String notificationSample5Title = 'Join Request';
  static const String notificationSample5Body =
      'Alex wants to join Beach trip.';
  static const String notificationSample6Title = 'Interest Paid Out!';
  static const String notificationSample6Body =
      'Your ROI has been added to your wallet.';
  static const String notificationSample7Title = 'Account Verified';
  static const String notificationSample7Body = "You're all set to use Vestie.";

  // ── Profile Screen ───────────────────────────────────────────────────────
  static const String profileTitle = 'Profile';
  static const String settingsLabel = 'Settings';
  static const String menuEditProfile = 'Edit Profile';
  static const String menuPaymentMethods = 'Payment Methods';
  static const String menuCompletedProjects = 'Completed Projects';
  static const String completedProjectsTitle = 'Completed Projects';
  static const String completedProjectsEmptyTitle = 'No completed projects yet';
  static const String completedProjectsEmptySubtitle =
      'Projects you finish will show up here.';
  static const String menuTransactionHistory = 'Transaction History';
  static const String menuKeyGuidelines = 'Vestie User Guidelines';
  static const String menuDeleteAccount = 'Delete Account';
  static const String deleteAccountConfirmBody =
      'This action will permanently delete your account and all your data. This cannot be undone.';
  static const String btnDeleteMyAccount = 'Delete My Account';

  // Vestie User Guidelines (profile screen — Figma)
  static const String guidelineYourRiskTitle = 'Your Risk';
  static const String guidelineYourRiskBody =
      'Users join pots and contribute at their own risk.';
  static const String guidelineNoGuaranteesTitle = 'No Guarantees';
  static const String guidelineNoGuaranteesBody =
      'Vestie does not guarantee the safety or return of any funds.';
  static const String guidelineKnowYourGroupTitle = 'Know Your Group';
  static const String guidelineKnowYourGroupBody =
      'Only send money to people you personally know and trust.';
  static const String guidelineBorrowingTermsTitle = 'Borrowing Terms';
  static const String guidelineBorrowingTermsBody =
      'Repayment terms and penalties are set by group leaders, not Vestie.';
  static const String guidelineDisputesTitle = 'Disputes';
  static const String guidelineDisputesBody =
      'Vestie is not responsible for resolving disputes between members.';
  static const String guidelineFinalContributionsTitle = 'Final Contributions';
  static const String guidelineFinalContributionsBody =
      'Contributions to active projects are final. Refunds are only issued if a project is cancelled.';
  static const String btnLogout = 'Log Out';

  // ── Edit Profile ─────────────────────────────────────────────────────────
  static const String editProfileTitle = 'Edit Profile';
  static const String labelFullName2 = 'Full Name';
  static const String labelUsername = 'Username';
  static const String hintUsername = '@username';
  static const String btnSaveChanges = 'Save Changes';

  // ── Payment Methods ──────────────────────────────────────────────────────
  static const String paymentMethodsTitle = 'Payment Methods';
  static const String emptyPaymentTitle = 'Add Payment Method';
  static const String emptyPaymentSubtitle =
      'No payment method added. Add a payment method to start contributing to projects.';
  static const String btnAddCard = 'Add Card';
  static const String cardPrimary = 'Primary';
  static const String setPrimaryLabel = 'Set as primary payment method';
  static const String setPrimarySubtitle =
      'We will use this payment method for all transactions';
  static const String removeCardLabel = 'Remove card';
  static const String removeCardSubtitle =
      'We will remove this card from your account.';

  // ── Add Card ─────────────────────────────────────────────────────────────
  static const String addCardTitle = 'Add Card';
  static const String labelCardHolderName = 'Card Holder Name';
  static const String labelCardNumber = 'Card Number';
  static const String labelExpiryDate = 'Expiry Date';
  static const String labelCvv = 'CVV';
  static const String hintCardHolder = 'Alex Johnson';
  static const String hintCardNumber = '0000 0000 0000 0000';
  static const String hintExpiry = 'MM/YY';
  static const String hintCvv = '000';
  static const String btnSaveCard = 'Save Card';
  static const String addCardStripeSubtitle =
      'Add your card securely with Stripe. Your card details are not stored on this device.';
  static const String addCardStripeSteps =
      'Tap Save Card — the Stripe payment sheet will open to enter your card.';
  static const String addCardStripeCancelled = 'Card setup cancelled.';
  static const String addCardStripeFailed =
      'Could not add card. Please try again.';
  static const String addCardMissingClientSecret =
      'Could not start card setup. Please try again.';
  static const String paymentMethodsLoadFailed =
      'Could not load payment methods. Pull to refresh or try again.';
  static const String errCardHolderRequired = 'Card holder name is required';
  static const String errCardNumberRequired = 'Card number is required';
  static const String errCardNumberInvalid =
      'Enter a valid 16-digit card number';
  static const String errExpiryRequired = 'Expiry date is required';
  static const String errExpiryInvalid = 'Enter a valid expiry (MM/YY)';
  static const String errExpiryPast = 'Card expiry date cannot be in the past';
  static const String errCvvRequired = 'CVV is required';
  static const String errCvvInvalid = 'CVV must be 3 or 4 digits';

  // ── Transaction History ───────────────────────────────────────────────────
  static const String transactionHistoryTitle = 'Transaction History';
  static const String memberActivityEmptyTransactions =
      'No transactions yet for this member.';
  static const String filterAllTx = 'All';
  static const String filterDeposits = 'Deposits';
  static const String filterWithdrawals = 'Withdrawals';
  static const String filterContributions = 'Contributions';
  static const String filterRepayments = 'Repayments';
  static const String filterFees = 'Fees';

  // ── Create Project Wizard ─────────────────────────────────────────────────
  // Amount screen
  static const String projectAmountTitle = 'Project Amount';
  static const String projectAmountPromptVacation =
      "What's your project goal amount?";
  static const String projectAmountPromptInvestment =
      "What's your project goal amount?";
  static const String projectAmountPromptEmergency =
      "What's your project goal amount?";
  static const String projectAmountEmptyDisplay = '\$0.00';

  // Step 1 – Details
  static const String createDetailsTitle = 'Project Details';
  static const String labelProjectName = 'Project Name';
  static const String hintProjectName = 'Family Vacations';
  static const String labelProjectDesc = 'Description';
  static const String hintProjectDesc =
      'A shared goal for flights, hotels and activities.';
  static const String labelCategory = 'Category';
  static const String labelDeadline = 'Deadline';
  static const String labelVisibility = 'Visibility';
  static const String visibilityPublic = 'Public';
  static const String visibilityPrivate = 'Private';

  // Category options (shown in dropdown)
  static const String catVacation = 'Vacation';
  static const String catEducation = 'Education';
  static const String catEmergency = 'Emergency';
  static const String catInvestment = 'Investment';
  static const String catOther = 'Other';

  // Three wizard flows — matches product screens
  static const String labelProjectSetup = 'How should this project work?';
  static const String flowSavingTitle = 'Save together';
  static const String flowSavingSubtitle =
      'Auto-save rhythm and shared savings before review.';
  static const String flowBorrowingTitle = 'Funds borrowing';
  static const String flowBorrowingSubtitle =
      'Members can borrow — set repayment window and penalty.';
  static const String flowSimpleTitle = 'Simple';
  static const String flowSimpleSubtitle =
      'Just the essentials — details then straight to review.';

  /// Only used for exhaustive UI switches; investment flow is category-driven.
  static const String flowInvestmentRoiCardTitle = 'Investment';
  static const String flowInvestmentRoiCardSubtitle =
      'Optional ROI for contributors — no borrowing.';

  // Investment path — optional ROI only (no borrowing)
  static const String labelRoiOptional = 'ROI (optional)';
  static const String roiOptionalHelper =
      'Set this to incentivize contributors. Paid out on project close.';

  // Saving path — Project Settings
  static const String createSavingSettingsTitle = 'Project Settings';
  static const String labelAutoSave = 'Auto-save';
  static const String autoSaveDescription =
      'Automatically save a portion of your income to this project.';
  static const String reviewSectionSaving = 'Project settings';
  static const String reviewLabelAutoSave = 'Auto-save';

  // Borrowing path (Vacation / Emergency — production frames)
  static const String createFundsBorrowingTitle = 'Borrowing Setup';
  static const String labelAnnualInterest = 'Interest rate (Annual %)';
  static const String hintAnnualInterest = '5%';

  /// Shown beside ROI / percent inputs (not stored in form state or API).
  static const String percentSign = '%';
  static const String labelRepaymentWindowDays = 'Repayment window (days)';
  static const String hintRepaymentDays = '30';
  static const String labelBorrowPenaltyPercent = 'Penalty (%)';
  static const String hintBorrowPenalty = '20';
  static const String reviewBorrowingEnabledLabel = 'Borrowing';
  static const String reviewRepaymentDaysLabel = 'Repayment window';
  static const String reviewPenaltyPercentLabel = 'Penalty';

  // Deprecated borrow-step labels retained for backwards copy search (unused in UI)
  static const String labelRoi = 'Interest rate (Annual %)';
  static const String roiHint = '5';
  static const String roiSubtitle = 'Shown only when borrowing is enabled.';
  static const String labelEnableBorrowing =
      'Enable borrowing for this project';
  static const String labelBorrowLimit = 'Default borrow limit per member';
  static const String labelRepaymentWindow = 'Repayment window (months)';
  static const String labelPenalty = 'Penalty (%)';
  static const String btnNext = 'Next';

  // Step 3 – Review
  static const String createReviewTitle = 'Review';
  static const String reviewSectionDetails = 'Project Details';
  static const String reviewSectionDescRules = 'Description & Rules';
  static const String reviewSectionBorrowing = 'Borrowing';
  static const String reviewSectionRoi = 'ROI';
  static const String btnEdit = 'Edit';
  static const String btnCreateProject2 = 'Create Project';
  static const String btnEditProject = 'Edit Project';
  static const String reviewRoiNotSet = 'Not set';

  // Success
  static const String projectCreatedTitle = 'Project Created';
  static const String projectEditedTitle = 'Project Edited';
  static const String shareViaWhatsapp = 'Share via Whatsapp';
  static const String btnGoToMyProject = 'Go to my Project';
  static const String linkCopied = 'Link copied!';

  /// Shared invite path host (production/staging on Azure until vestie.app is live).
  static const String shareBaseDomain =
      'vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/join';

  /// Text before the invite URL in WhatsApp (URL may already include `https://`).
  static const String shareWhatsappPrefix = 'Join my project: ';

  /// Full message for `wa.me` — avoids `https://https://` when [link] already has a scheme.
  static String shareWhatsappMessage(String link) {
    final t = link.trim();
    if (t.isEmpty) return shareWhatsappPrefix.trimRight();
    final normalized = t.startsWith('http://') || t.startsWith('https://')
        ? t
        : 'https://$t';
    return '$shareWhatsappPrefix$normalized';
  }

  // ── Review screen row labels ──────────────────────────────────────────────
  static const String reviewLabelName = 'Name';
  static const String reviewLabelGoal = 'Goal';
  static const String reviewLabelDeadline = 'Deadline';
  static const String reviewLabelCategory = 'Category';
  static const String reviewLabelDescription = 'Description';
  static const String reviewLabelVisibility = 'Visibility';
  static const String reviewLabelType = 'Type';
  static const String reviewLabelLimit = 'Limit';
  static const String reviewLabelWindow = 'Window';
  static const String reviewLabelPenalty = 'Penalty';
  static const String reviewLabelProjectFlow = 'Setup';
  static const String reviewValuePublic = 'Public';
  static const String reviewValuePrivate = 'Private';
  static const String reviewValueEnabled = 'Enabled';
  static const String reviewValueDisabled = 'Disabled';
  static const String reviewValueDays = 'days';

  // ── Form placeholders & hints ─────────────────────────────────────────────
  static const String deadlinePlaceholder = 'MM/DD/YYYY';

  /// Picker / field action — drops optional project end date (no `endsAtUtc` on create).
  static const String btnRemoveDeadline = 'Remove deadline';
  static const String hintBorrowLimit = '250';
  static const String hintRepaymentWindow = '30';
  static const String hintPenalty = '20';

  // ── Validation errors — Create Project ───────────────────────────────────
  static const String errProjectNameRequired = 'Project name is required';
  static const String errProjectNameShort = 'At least 3 characters required';
  static const String errDescRequired = 'Description is required';
  static const String errDeadlineRequired = 'Deadline is required';
  static const String errDeadlinePast = 'Deadline cannot be in the past';
  static const String errBorrowLimitRequired = 'Borrow limit is required';
  static const String errBorrowLimitInvalid = 'Enter a valid amount';
  static const String errWindowRequired = 'Repayment window is required';
  static const String errWindowInvalid = 'Enter a valid number of days';
  static const String errAnnualRoiRequired = 'Interest rate is required';
  static const String errAnnualRoiInvalid = 'Enter a valid percentage (0–100)';
  static const String errRepaymentMonthsRequired =
      'Repayment period is required';
  static const String errRepaymentMonthsInvalid =
      'Enter months between 1 and 120';
  static const String errRepaymentDaysRequired = 'Repayment window is required';
  static const String errRepaymentDaysInvalid = 'Enter days between 1 and 3650';
  static const String errVotingWindowRequired = 'Voting window is required';
  static const String errVotingWindowInvalid =
      'Enter a number between 1 and 365';
  static const String errPenaltyRequired = 'Penalty is required';
  static const String errPenaltyInvalid = 'Enter a value between 0–100';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String permissionCameraTitle = 'Camera access needed';
  static const String permissionPhotosTitle = 'Photo library access needed';
  static const String permissionCameraDenied =
      'Camera access was denied. You can enable it in Settings.';
  static const String permissionPhotosDenied =
      'Photo library access was denied. You can enable it in Settings.';
  static const String permissionCameraSettingsBody =
      'Open Settings → Vestie → Camera and allow access to take a profile photo.';
  static const String permissionPhotosSettingsBody =
      'Open Settings → Vestie → Photos and allow access to choose a profile picture.';
  static const String permissionNotificationsTitle = 'Enable notifications';
  static const String permissionNotificationsDenied =
      'Notifications are off. Enable them in Settings to get project and wallet updates.';
  static const String permissionNotificationsPromptBody =
      'Get alerts for contributions, withdrawals, and project activity. You can change this anytime in Settings.';
  static const String permissionNotificationsSettingsBody =
      'Open Settings → Vestie → Notifications and turn notifications on.';
  static const String btnOpenSettings = 'Open Settings';
  static const String btnEnableNotifications = 'Enable';
  static const String btnNotNow = 'Not now';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
  static const String profileChangeImage = 'Change Image';
  static const String profileRemoveImage = 'Remove Image';
  static const String profilePhotoUploading = 'Uploading photo...';
  static const String profilePhotoRemoving = 'Removing photo...';
  static const String cardSavedSuccess = 'Card saved successfully!';
  static const String cardRemovedSuccess = 'Card removed.';

  // ── Router / placeholder stubs ────────────────────────────────────────────
  static const String keyGuidelinesComingSoon = 'Key Guidelines — Coming Soon';
  static const String routeNotFound = 'Route Not Found';

  // ── Wallet ───────────────────────────────────────────────────────────────
  static const String walletTitle = 'Wallet';
  static const String walletAmountLabel = 'Wallet Amount';

  /// Wallet tab — balance heading (Figma).
  static const String walletBalanceHeading = 'Wallet Balance';
  static const String walletPendingWithdrawalLabel = 'Pending withdrawal';
  static const String kycOnboardingTitle = 'KYC';
  static const String kycOnboardingUrlMissing =
      'Could not start verification. Please try again.';
  static const String kycRequiredForWithdrawTitle = 'Verification required';
  static const String kycRequiredForWithdrawBody =
      'Complete identity verification before withdrawing funds.';
  static const String kycOnboardingCompleteHint =
      'Identity verified. Tap Continue to proceed.';
  static const String kycOnboardingPendingReviewHint =
      'Verification is under review. Tap Continue once approved.';
  static const String kycOnboardingIncompleteHint =
      'Verification incomplete. Tap Continue to finish onboarding.';
  static const String kycOnboardingRejectedHint =
      'Verification was rejected. Contact support or try again.';
  static const String kycOnboardingCanceled = 'Verification canceled.';
  static const String stripeBrowserOnboardingKycBody =
      'Opening secure verification in your browser…';
  static const String stripeBrowserOnboardingBankBody =
      'Opening bank linking in your browser…';
  static const String stripeBrowserOnboardingReturnHint =
      'If you see a “Continue in the Vestie app” page in the browser, '
      'close that tab — you should return here automatically. '
      'If not, tap Return to Vestie below.';
  static const String stripeBrowserOnboardingReturnToApp = 'Return to Vestie';
  static const String stripeBrowserOnboardingOpenAgain = 'Open browser again';
  static const String stripeBrowserOnboardingCheckStatus =
      "I've finished — check status";
  static const String stripeBrowserOnboardingLaunchFailed =
      'Could not open the browser. Please try again.';
  static const String btnVerifyIdentity = 'Verify identity';
  static const String bankLinkOnboardingTitle = 'Link bank account';
  static const String bankLinkOnboardingUrlMissing =
      'Could not start bank linking. Please try again.';
  static const String bankLinkOnboardingIncompleteHint =
      'Bank linking incomplete. Try again to add an account.';
  static const String bankLinkOnboardingCanceled = 'Bank linking canceled.';
  static const String btnAddBankAccount = 'Add bank account';
  static const String selectBankAccountTitle = 'My Accounts';
  static const String menuMyAccounts = 'My Accounts';
  static const String emptyMyAccountsTitle = 'Add Bank Account';
  static const String emptyMyAccountsSubtitle =
      'No bank account linked. Add a bank account to receive withdrawals.';
  static const String setDefaultBankLabel = 'Set as default bank account';
  static const String setDefaultBankSubtitle =
      'We will use this bank account for withdrawals';
  static const String removeBankLabel = 'Remove bank account';
  static const String removeBankSubtitle =
      'We will remove this bank account from your profile.';
  static const String bankRemovedSuccess = 'Bank account removed.';
  static const String bankAccountsLoadFailed =
      'Could not load bank accounts. Please try again.';
  static const String bankAccountDefaultLabel = 'Default';
  static const String bankLinkEmptySubtitle =
      'Link a bank account to receive withdrawals.';
  static const String withdrawInsufficientBalance =
      'Insufficient wallet balance for this withdrawal.';
  static const String withdrawSelectBankRequired = 'Select a bank account.';
  static const String walletBalanceLabel = 'Wallet Balance:';
  static const String btnDepositFunds = 'Deposit Funds';
  static const String btnWithdrawFunds = 'Withdraw Funds';
  static const String depositFundsTitle = 'Deposit';
  static const String withdrawFundsTitle = 'Withdraw';
  static const String depositAmountSubtitle = 'Enter Amount';
  static const String labelDepositAmount = 'Deposit Amount';
  static const String withdrawAmountSubtitle = 'Add Amount';
  static const String confirmDepositTitle = 'Confirm Deposit';
  static const String confirmWithdrawTitle = 'Confirm Withdraw';
  static const String btnConfirmDeposit = 'Confirm Deposit';
  static const String walletDepositDetailsTitle = 'Deposit Details';
  static const String walletWithdrawDetailsTitle = 'Withdraw Details';
  static const String walletDepositingLabel = 'Depositing';
  static const String walletWithdrawingLabel = 'Withdrawing';
  static const String walletMethodLabel = 'Method';
  static const String walletToLabel = 'To';
  static const String walletDepositFeeLabel = 'Deposit Fee';
  static const String walletWithdrawalFeeLabel = 'Withdrawal Fee';
  static const String walletProcessingTimeLabel = 'Processing Time';
  static const String walletProcessingTimeValue = '1-3 business days';
  static const String walletNewBalanceAfterLabel = 'New Balance After';
  static const String walletFeeNone = 'None';
  static const String labelAmount = 'Amount';
  static const String labelFee = 'Fee';
  static const String labelFrom = 'From';
  static const String labelTo = 'To';
  static const String btnConfirm = 'Confirm';
  static const String btnDone = 'Done';
  static const String depositSuccessTitle = 'Deposit Successful';
  static const String depositStripeNotConfigured =
      'Card payments are not available right now. Please try again later.';
  static const String depositMissingClientSecret =
      'Could not start card payment. Please try again.';
  static const String depositSelectCardRequired =
      'Select a payment card to deposit with.';
  static const String depositMissingPaymentIntentId =
      'Payment could not be verified. Check your wallet balance.';
  static const String depositPaymentCancelled = 'Deposit cancelled.';
  static const String depositPaymentFailed =
      'Card payment failed. Check your card or try another payment method.';
  static const String depositChangePaymentMethod = 'Change card';
  static const String depositCardInsufficientHint =
      'This card could not complete the payment. Try another card or check your bank.';
  static const String depositPollTimeout =
      'Payment is still processing. Check your wallet shortly.';
  static const String depositStatusAborted =
      'Deposit was aborted before completion.';
  static const String depositStatusExhausted =
      'Deposit could not be completed. Please try again.';
  static String depositSuccessBody(String amount) =>
      '$amount has been added to your wallet.';
  static const String withdrawSuccessTitle = 'Withdrawal Requested';
  static const String withdrawEtaPrefix = 'Your ';
  static const String withdrawEtaSuffix = ' will arrive in 1-3';
  static const String withdrawEtaLineTwo = 'business days.';
  static const String repaySentSuccessTitle = 'Repay Sent Successfully';
  static const String repaySentPrefix = 'You’ve sent repay amount of ';
  static const String repaySentSuffix = ' to';
  static const String contributionSuccessTitle = 'Contribution Successful';
  static const String btnBackToWallet = 'Back to Wallet';
  static const String addAmount = 'Add Amount';

  // ── Withdraw method & confirm (Figma withdrawal flow) ──────────────────────
  static const String withdrawMethodTitle = 'Withdraw Method';
  static const String withdrawStandardTitle = 'Standard Withdraw';
  static const String withdrawStandardSubtitle = 'Delivery: 1-3 business days';
  static const String withdrawInstantTitle = 'Instant Withdraw';
  static const String withdrawInstantSubtitle = 'Delivery: Arrives in minutes';
  static const String withdrawFeeDisclaimerPrefix = 'Fee: ';
  static const String withdrawFeeDisclaimerInstant = '1.5% of withdraw amount';
  static const String withdrawInstantFeeFooter = 'Fee: 1.5% of withdraw amount';
  static const String badgeInstant = 'Instant';
  static const String labelWithdrawalAmount = 'Withdrawal Amount';
  static const String labelYouWillReceive = 'You will receive';
  static const String withdrawProcessingInstantValue = '30 Mins';
  static const String btnConfirmInstantWithdraw = 'Confirm Instant Withdraw';
  static const String btnConfirmStandardWithdraw = 'Confirm Standard Withdraw';

  static String withdrawFeeInstantRow({
    required double feePercent,
    required double feeAmount,
  }) {
    final pct = feePercent == feePercent.roundToDouble()
        ? '${feePercent.toInt()}%'
        : '${feePercent.toStringAsFixed(1)}%';
    final fee = AppFormatters.formatCurrency(feeAmount);
    return '$pct (-$fee)';
  }

  static String withdrawSuccessBodyInstant(String amountFormatted) =>
      'Your $amountFormatted will arrive within 30 Mins.';

  static String withdrawSuccessBodyStandard(String amountFormatted) =>
      'Your $amountFormatted will arrive in 1-3 business days.';

  // ── Project Contribute / Borrow (from project detail) ─────────────────────
  static const String contributeScreenTitle = 'Contribute';
  static const String contributeConfirmHeader = 'Confirm';
  static const String labelPaymentMethod = 'Payment Method';
  static const String labelPaymentFrom = 'Payment from';
  static const String labelBreakdown = 'Breakdown';
  static const String labelContributionAmount = 'Contribution amount';
  static const String labelVestieFee3 = 'Vestie fee (3%)';
  static const String labelTotalDeduction = 'Total Deduction';
  static const String contributeNonRefundable =
      'I understand this contribution is non-refundable';
  static const String contributeNonRefundableRequired =
      'Please confirm that this contribution is non-refundable.';
  static const String contributeWalletInsufficientSubtitle =
      'Insufficient balance for this total. Tap above to choose a card.';
  static const String contributeSelectCardRequired =
      'Select a payment card to continue.';
  static const String labelSelectPaymentCard = 'Select card';
  static const String contributeProjectGoalReached =
      'This project has reached its funding goal.';
  /// Proactive hint on the amount step (project goal cap).
  static String contributeOnlyAmountHint(String maxFormatted) =>
      'You can contribute only $maxFormatted to reach the project goal.';
  /// Shown when the entered amount is above [contributeOnlyAmountHint].
  static String contributeOnlyAmountExceeded(String maxFormatted) =>
      'Please lower your amount. You can contribute only $maxFormatted.';
  static String contributeDepositForWalletMessage(String amountFormatted) =>
      'Contributions are paid from your Vestie wallet. Deposit at least '
      '$amountFormatted to continue, then return and pay with Wallet.';
  static const String walletLockedInProjectsLabel = 'Locked in projects';
  static String projectContributorCountLabel(int count) =>
      count == 1 ? '1 contributor' : '$count contributors';
  static const String borrowScreenTitle = 'Borrow';
  static const String borrowTermsTitle = 'Borrow Terms';
  static const String labelBorrowLimitChip = 'Borrow Limit';
  static const String labelNote = 'Note';
  static const String hintBorrowNote = 'Add a short note (optional)';
  static const String sectionBorrowAmount = 'Borrow Amount';
  static const String labelFullAmountDueBy = 'Full amount due by';
  static const String sectionPenalty = 'Penalty';
  static const String labelPenaltyIfMissed = 'Penalty if missed';
  static const String labelPenaltyApplies = 'Penalty applies';
  static const String penaltyValuePercent = '10% of borrowed amount';
  static const String penaltyValueOneTime = 'One time';
  static const String btnSubmitBorrowRequest = 'Submit Borrow Request';
  static const String borrowSubmitRetryHint =
      'Tap Submit to try again, or go back to change the amount.';
  static const String borrowRequestSubmitted = 'Request Submitted';
  static const String btnBackToProject = 'Back to Project';
  static const String borrowAmountExceedsLimit =
      'Amount exceeds your borrow limit for this project.';
  static const String borrowCannotBorrowNow =
      'You cannot borrow at this time.';
  static const String borrowDefaultReason = 'Borrow request';
  static const String borrowLimitSetByLeaderSuffix = '(set by leader)';
  static const String borrowSuccessSubtitlePrefix = 'Your ';
  static const String borrowSuccessSubtitleSuffix =
      ' borrow request has been sent to the group for voting and leader review.';
  static String borrowAgreementFallback(
    String amountFormatted,
    String dueByLabel,
  ) =>
      'I agree to repay $amountFormatted in full by $dueByLabel';
  // ── Recent Activity ───────────────────────────────────────────────────────
  static const String borrowedLabel = 'Borrowed';
  static const String recentActivityHeader = 'Recent Activity';
  static const String walletEmptyActivityTitle = 'No Recent Activity';
  static const String walletEmptyActivitySubtitle =
      'All of your transactions will appear here.';
  static const String txWalletDeposit = 'Wallet Deposit';
  static const String txContributionPrefix = 'Contribution: ';
  static const String txBorrowPrefix = 'Borrow: ';

  // ── Project Detail ────────────────────────────────────────────────────────
  static const String projectDetailTitle = 'Project';
  static const String announcementTitle = 'Announcement';
  static const String announcementPlaceholder =
      'Any announcement will come up here';
  static const String noMoreContributionTitle = 'No More Contribution';
  static const String noMoreContributionBody =
      'You can no longer contribute to this investment as leader has closed this project.';

  /// Member (non-investment) projects completed by the leader — vacations / emergency.
  static const String projectCompletedUserTitle = 'No more contribution';
  static const String projectCompletedUserBody =
      'The group leader has marked this project as complete. You can no longer add contributions or borrow from this project.';
  static const String btnContribute = 'Contribute';
  static const String btnBorrow = 'Borrow';
  static const String borrowRequiresCoLeaderMessage =
      'Add a co-leader to your project first. After that, you can submit a borrow request.';
  static const String tabBorrowRequests = 'Borrow Requests';
  static const String tabMembers = 'Members';
  static const String tabMember = 'Member';
  static const String tabManageMembers = 'Manage Members';
  static const String labelContributedWithColon = 'Contributed: ';
  static const String overdueLabel = 'Overdue';
  static const String requestedAmount = 'Requested Amount';
  static const String viewAllRequests = 'View All Requests';
  static const String viewAllMembers = 'View All Members';
  static const String groupMembersTitle = 'Group Members';
  static const String borrowRequestsEmpty = 'No Borrow Request';
  static const String borrowRequestsEmptySubtitle =
      'Great, you don\'t have any borrow requests.';
  static const String projectDetailBorrowRequestsEmpty =
      'No borrow requests yet.';
  static const String borrowRequestsTitle = 'Borrow Requests';
  static const String myBorrowRequestTitle = 'My Borrow Request';
  static const String myBorrowTitle = 'My Borrow';
  static const String myBorrowAmountLabel = 'Borrow Amount';
  static const String myBorrowBorrowDateLabel = 'Borrow Date';
  static const String myBorrowDueDateLabel = 'Due date';
  static const String myBorrowTotalRepaymentLabel = 'Total Repayment';
  static const String myBorrowBreakdownProjectNameLabel = 'Project name';
  static const String repayScreenTitle = 'Repay';
  static const String labelRepayAmount = 'Repay Amount';
  static const String btnConfirmRepay = 'Confirm Repay';
  static const String btnRepayBorrowAmount = 'Repay Borrow Amount';
  static const String borrowCannotRepayYet = 'This borrow cannot be repaid yet.';
  static String borrowRepaySuccessBody(String amount, String projectName) =>
      'You\'ve successfully repaid $amount to $projectName.';
  static String borrowRepayPenaltyValue(int percent, String amountFormatted) =>
      '$percent% ($amountFormatted)';
  static const String btnPreviewApprovedBorrowRequest =
      'Preview approved borrow request UI';
  static const String myBorrowMemberVotesLabel = 'Member Votes';
  static const String myBorrowPendingBanner = 'Pending — waiting for decision';
  static const String myBorrowHistoryLabel = 'Borrow History';
  static const String btnPreviewPendingBorrowRequest =
      'Preview pending borrow request UI';
  static const String btnMakeBorrowRequest = 'Make Request';
  static const String btnCancelBorrowRequest = 'Cancel Request';
  static const String cancelBorrowRequestDialogTitle = 'Are You Sure?';
  static const String cancelBorrowRequestDialogBody =
      'Are you sure you want to cancel this request?';
  static const String btnYesLeave = 'Yes leave';
  static const String borrowRequestCancelledTitle =
      'Your request has been cancelled';
  static const String borrowRequestCancelledBody =
      'You\'ve cancelled your on going borrow request';
  static const String borrowHistoryApproved = 'Approved';
  static const String borrowHistoryCancelled = 'Cancelled';
  static const String borrowHistoryRejected = 'Rejected';
  static const String upvoteLabel = 'Upvote';
  static const String downvoteLabel = 'Downvote';
  static const String upvotedStatusLabel = 'You’ve Upvoted this Requested';
  static const String downvotedStatusLabel = 'You’ve Downvote this Requested';
  static const String acceptLabel = 'Accept';
  static const String rejectLabel = 'Reject';
  static const String educationLoan = 'Education Loan';
  static const String goalPrefix = 'Goal ';
  static const String memberProfileSuffix = ' Profile';
  static const String contributedLabel = 'Contributed';
  static const String contributionsLabel = 'Contributions';
  static const String borrowedLabelShort = 'Borrowed';
  static const String btnMakeCoLeader = 'Make Co-Leader';
  static const String btnRemoveCoLeader = 'Remove Co-Leader';
  static const String btnTakeAction = 'Take Action';
  static const String btnRemoveMember = 'Remove from Group';
  static String memberOverdueBorrowNotice(int overdueBorrowCount) {
    if (overdueBorrowCount <= 0) {
      return 'This user has overdue borrow(s).';
    }
    if (overdueBorrowCount == 1) {
      return 'This user has 1 overdue borrow.';
    }
    return 'This user has $overdueBorrowCount overdue borrows.';
  }

  static const String penaltyActionTitle = 'Penalty Action';
  static const String markAsDefaulted = 'Mark as Defaulted';
  static const String removeMemberConfirmTitle = 'Remove Member?';
  static const String removeMemberConfirmBody =
      'Are you sure you want to remove this member? This action cannot be undone.';
  static const String removeMemberSuccessTitle = 'Member Removed';
  static const String removeMemberSuccessBody =
      'This member has been removed from the project.';
  static const String markDefaultedConfirmTitle = 'Mark as Defaulted';
  static const String markDefaultedConfirmBody =
      'Marking a user as defaulted blocks them from contributing or borrowing in any group until all dues are cleared.';
  static const String markDefaultedSuccessTitle = 'Member Marked as Defaulted';
  static const String markDefaultedSuccessBody =
      'This member can no longer contribute or borrow in any group until all dues are cleared.';
  static const String makeCoLeaderConfirmTitle = 'Make Co-Leader?';
  static const String makeCoLeaderConfirmBody =
      'This user will be able to approve borrow requests, post announcements, and manage members. You will remain the main leader.';
  static const String removeCoLeaderConfirmTitle = 'Remove Co-Leader?';
  static const String removeCoLeaderConfirmBody =
      'This user will return to a regular member and lose the ability to approve requests and manage the group.';
  static const String coLeaderAssignedTitle = 'Co-Leader Assigned';
  static const String coLeaderAssignedBody =
      'User is now Co-Leader and can approve requests and manage members.';
  static const String coLeaderRemovedTitle = 'Co-Leader Removed';
  static const String coLeaderRemovedBody = 'User is now a regular member.';
  static const String btnRemove = 'Remove';
  static const String btnCancel = 'Cancel';
  static const String btnOk = 'Ok';
  static const String btnNo = 'No';
  static const String penaltyBorrowedLabel = 'Borrowed';
  static const String penaltyDueLabel = 'Due';
  static const String penaltyOverdueLabel = 'Overdue';
  static const String penaltyPenaltyLabel = 'Penalty';
  static const String penaltyTotalOwedLabel = 'Total owed';
  static const String penaltyBorrowedAmount = '\$250.00';
  static const String penaltyDueAmount = '\$250';
  static const String penaltyOverdueDateValue = 'Apr 1, 2025';
  static const String penaltyChargeValue = '\$20.00';
  static const String penaltyTotalOwedValue = '\$270.00';
  static const String memberTxDateMar11 = 'Mar 11';
  static const String memberTxDateMar12 = 'Mar 12';
  static const String approveBorrowRequestTitle = 'Approve Borrow Request?';
  static const String rejectBorrowRequestTitle = 'Reject Borrow Request';
  static const String borrowApprovedTitle = 'Approve Borrow Request?';
  static const String borrowRejectedTitle = 'Borrow Request Rejected';
  static const String upvoteBorrowRequestTitle = 'Upvote Borrow Request?';
  static const String downvoteBorrowRequestTitle = 'Downvote Borrow Request?';
  static const String approveLabel = 'Approve';
  static const String rejectShortLabel = 'Reject';

  static String borrowRequestActionDescription({
    required bool isApprove,
    required String memberName,
    required String amount,
  }) {
    final action = isApprove ? 'approving' : 'rejecting';
    return 'You’re $action borrow request\nfrom $memberName of \$$amount';
  }

  // ── Leader Project Actions ────────────────────────────────────────────────
  static const String menuLeaderProjectSettings = 'Project settings';
  static const String leaderProjectSettingsTitle = 'Project settings';
  static const String menuJoinRequests = 'Join Requests';
  static const String menuAddAnnouncement = 'Add Announcement';
  static const String menuEditProject = 'Edit Project';
  static const String menuInviteMembers = 'Invite Members';
  static const String menuMarkSuccessful = 'Mark as Successful';
  static const String menuStopContributions = 'Stop the contribution';
  static const String menuCancelProject = 'Cancel Project';

  // ── Member project actions (Vacation / Emergency detail header)
  static const String menuProjectFundsHistory = 'Project Funds History';
  static const String menuMyBorrows = 'My Borrows';
  static const String menuLeaveProject = 'Leave Project';
  static const String projectFundsHistoryEmpty =
      'No contributions recorded yet.';
  static const String projectFundsCurrentPotBalance = 'Current Pot Balance';
  static const String projectFundsTotalContribution = 'Total Contribution';
  static const String projectFundsActiveBorrows = 'Active Borrows';
  static const String projectFundsContributionHistory = 'Contribution History';
  static const String markSuccessfulIntro1 =
      'Marking the project as successful will notify all members to vote. '
      'A majority must agree before funds are released to your wallet.';
  static const String markSuccessfulIntro2 =
      'Voting window: 21 days. If majority disagrees, all contributions are refunded.';
  static const String stopContributionsIntro1 =
      'All members will be notified to vote. If the majority agrees, '
      'contributions will stop and you can begin investing the funds.';
  static const String btnStopContributions = 'Stop Contributions';
  static const String btnInitiateSuccessVote = 'Initiate Success Vote';
  static const String startSuccessVoteDialogTitle = 'Start the success vote?';
  static const String btnStartVoting = 'Start Voting';
  static const String votingWindowTitle = 'Voting window';
  static const String labelEnterVotingWindowDays =
      'Enter voting window(in days)';
  static const String hintVotingWindowDays = '1-30';
  static const String votingWindowDaysInfo =
      'Members can vote to approve marking the project successful during this window.';
  static const String stopContributionsVotingWindowInfo =
      'Members can vote to stop project contributions during this window.';
  static const String successVoteStartedMessage =
      'Success vote started. Members have been notified.';
  static const String stopContributionsVoteStartedTitle = 'Vote has started';
  static const String stopContributionsVoteStartedSubtitle =
      'The vote has started. A decision will be made once the voting window closes.';
  static const String cancelProjectHeroWarning =
      'This will permanently cancel the project for all members.';
  static const String cancelProjectRefundParagraph =
      'All contributions will be automatically refunded to each member\'s wallet. '
      'Defaulted members receive no refund.';
  static const String btnYesCancel = 'Yes, Cancel';
  static const String projectCancelledTitle = 'Project Cancelled';
  static const String btnBackToHome = 'Back to Home';
  static const String btnViewDetails = 'View Details';
  static const String defaultedNoRefundShort =
      'Defaulted members received no refund.';
  static const String hintAnnouncementText = 'Type your announcement...';
  static const String deleteAnnouncementLabel = 'Delete announcement';
  static const String createAnnouncementTitle = 'Create Announcement';
  static const String announcementHeadingLabel = 'Announcement Heading';
  static const String announcementContentLabel = 'Announcement Content';
  static const String announcementHeadingHint = 'Deposit Issued';
  static const String announcementContentHint =
      'Good News, Your deposit has been issued';
  static const String announcementAutoRemoveNote =
      'Announcement will auto remove after 24 hours';
  static const String btnCreateAnnouncement = 'Create Announcement';
  static const String errAnnouncementHeadingRequired =
      'Announcement heading is required';
  static const String errAnnouncementHeadingShort =
      'At least 3 characters required';
  static const String errAnnouncementContentRequired =
      'Announcement content is required';
  static const String errAnnouncementContentShort =
      'At least 5 characters required';
  static const String joinRequestApprovedTitle = 'Join Request Approved';
  static const String joinRequestDeclinedTitle = 'Join Request Declined';
  static const String joinRequestApprovedPrefix =
      'You’ve approved the join request from ';
  static const String joinRequestDeclinedPrefix =
      'You’ve declined the join request from ';
  static const String joinRequestApproveLabel = 'Accept';
  static const String joinRequestDeclineLabel = 'Decline';

  // ── Member: join result (after leader approves / rejects) ──────────────
  static const String userJoinRequestApprovedStatusTitle = 'Request Approved';
  static const String userJoinRequestApprovedStatusBody =
      'The group leader has approved your request to join this project. You can now contribute and take part in the pot.';
  static const String userJoinRequestRejectedStatusTitle = 'Not Approved';
  static const String userJoinRequestRejectedStatusBody =
      'The group leader did not approve your request to join this project. You can still discover other projects on Vestie.';

  // ── Member: success vote (leader started vote) ───────────────────────
  static const String userSuccessVoteBannerTitle =
      'The leader has called a success vote!';
  static const String userSuccessVoteBannerBody =
      'Vote before the deadline to help decide if the project should be marked as successful.';
  static const String userSuccessVoteDeadlineLabel = 'Voting deadline';
  static const String userSuccessVoteStatGoal = 'Goal Amount';
  static const String userSuccessVoteStatMembers = 'Members';
  static const String userSuccessVoteTotalRaised = 'Total Raised';
  static const String userSuccessVoteQuestion =
      'Do you agree this project was successful?';
  static const String userSuccessVoteYes = 'Yes, It was';
  static const String userSuccessVoteNotYet = 'No,Not Yet';
  static const String userSuccessVoteFooter =
      'Your vote is anonymous. A majority \'Yes\' releases funds to all members. '
      '\'No\' majority refunds contributions.';
  static const String userSuccessVoteMemberVotesLabel = 'Member Votes';
  static const String userSuccessVoteThumbsUp = 'Thumbs Up';
  static const String userSuccessVoteThumbsDown = 'Thumbs Down';
  static const String userSuccessVoteNotVoted = 'Not voted';
  static const String userSuccessVoteAgreedTitle = 'You\'ve agreed on this';
  static const String userSuccessVoteAgreedBody =
      'You\'ve marked the project as complete. If the majority agrees, all '
      'contributions will be sent to the leader.';
  static const String userSuccessVoteDisagreedTitle =
      'You\'ve disagreed on this';
  static const String userSuccessVoteDisagreedBody =
      'You\'ve marked the project as incomplete. If the majority agrees, all '
      'money will be refunded to wallet.';
  static const String btnPreviewSuccessVote = 'Preview success vote UI';
  static const String btnViewSuccessVotes = 'View Success Votes';
  static const String btnPreviewViewSuccessVotes =
      'Preview View Success Votes UI';

  // ── Group leader: active success vote (Figma voting window) ───────────
  static const String leaderSuccessVoteWindowClosesIn =
      'Voting window closes in';
  static const String leaderSuccessVoteTimerHr = 'Hr';
  static const String leaderSuccessVoteTimerMin = 'Min';
  static const String leaderSuccessVoteTimerSec = 'Sec';
  static const String leaderSuccessVoteNotYetVoted = 'Not yet voted';
  static const String leaderSuccessVoteStatusWaiting = 'Waiting';

  static String leaderSuccessVoteMajorityNeeded(int required, int total) =>
      'Majority needed: $required of $total members must Agree to release funds.';
  static const String btnPreviewVoteOutcomeApproved =
      'Preview vote approved UI';
  static const String btnPreviewVoteOutcomeRejected =
      'Preview vote rejected UI';

  // ── Member: success vote final outcome (majority result) ─────────────
  static const String projectVoteApprovedTitle = 'Project Approved!';
  static const String projectVoteApprovedSubtitle =
      'Majority of members agreed.';
  static const String projectVoteNotApprovedTitle = 'Project Not Approved';
  static const String projectVoteNotApprovedSubtitle =
      'Majority of members disagreed.';
  static const String projectVoteFundsReleasedToGlWallet =
      'Funds released to GL wallet';
  static const String projectVoteContributionsRefunding =
      'Contributions being refunded';
  static const String projectVoteSummaryLabel = 'Vote Summary';
  static const String projectVoteAgreedLabel = 'Agreed';
  static const String projectVoteDisagreedLabel = 'Disagreed';

  /// Group leader — vacation / emergency vote approved (Figma).
  static const String btnStartDistributing = 'Start Distributing';

  /// Group leader — vacation / emergency vote not approved (Figma).
  static const String btnResumeContributions = 'Resume Contributions';

  static String projectVoteMembersOfTotal(int voted, int total) =>
      '$voted of $total members';

  // ── Member: immediate feedback after voting (mark complete) ────────────
  static const String markUserVotedSuccessTitle = 'Approved';
  static const String markUserVotedSuccessBody =
      'You’ve marked the project as complete. If the majority agrees, funds will be released to the creator.';
  static const String markUserVotedIncompleteTitle = 'Not Approved';
  static const String markUserVotedIncompleteBody =
      'You’ve marked the project as incomplete. If the majority disagrees, all contributions will be refunded.';
  static const String shareQrCode = 'Share QR Code';
  static const String copyCodeFromBelow = 'Or copy code from below';
  static const String inviteLinkSample =
      'https://vestie-backend-byexejcphyhaapfy.centralus-01.azurewebsites.net/join/SAMPLE';
  static String inviteMembersTitle(String projectName) =>
      'Invite to $projectName';
  static const String inviteMembersSelectVffHint = 'Tap to select VFFs';
  static const String inviteMembersOrShareVia = 'or share Via';
  static const String inviteShareOutsideVestie = 'Share outside Vestie';

  static String inviteMembersInviteSelected(int count) =>
      'Invite ($count selected)';

  static String removeMemberTitle(String memberName) => 'Remove $memberName';

  static String removeMemberBody(String memberName) =>
      'Are you sure you want to remove $memberName? This action cannot be undone.';

  static String makeCoLeaderDescription(String memberName) =>
      '$memberName will be able to approve borrow requests, post announcements, and manage members. You\'ll remain the main leader.';

  static String removeCoLeaderDescription(String memberName) =>
      '$memberName will return to a regular member. They will lose the ability to approve requests and manage the group.';

  static String startSuccessVoteDialogBody(int memberCount) {
    final unit = memberCount == 1 ? 'member' : 'members';
    return 'All $memberCount $unit will be notified and asked to vote. You cannot undo this.';
  }

  static String cancelProjectUnpaidBorrowsLine(int count) {
    final unit = count == 1 ? 'member' : 'members';
    return '$count $unit have unpaid borrows - they will be marked as DEFAULTED.';
  }

  static String cancelProjectConfirmTitle(String projectName) =>
      'Are you sure you want to cancel $projectName?';

  static String projectCancelledDescription(String projectName) =>
      '$projectName has been permanently cancelled. All eligible contributions '
      'have been refunded to members\' wallets.';

  static String coLeaderAssignedDescription(
    String memberName,
    String projectName,
  ) =>
      '$memberName is now Co-Leader of $projectName. They can approve requests and manage members.';

  static String coLeaderRemovedDescription(
    String memberName,
    String projectName,
  ) => '$memberName is now a regular member of $projectName.';

  static String borrowApprovePrefix() =>
      'You’re approving borrow request from ';

  static String borrowRejectPrefix() => 'You’re rejecting borrow request from ';

  static String borrowUpvotePrefix() => 'You’re upvoting borrow request from ';

  static String borrowDownvotePrefix() =>
      'You’re downvoting borrow request from ';
}
