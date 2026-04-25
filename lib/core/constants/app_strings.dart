class AppStrings {
  AppStrings._();

  // App Meta
  static const String appName = 'Vestie';
  
  // General
  static const String errorGeneric      = 'Something went wrong. Please try again.';
  static const String errorNetwork      = 'No internet connection. Please check your network.';
  static const String errorUnauthorized = 'Session expired. Please log in again.';
  static const String errorServer       = 'Server error. Please try again later.';
  static const String errorTimeout      = 'Request timed out. Please try again.';

  // ── Error Dialog ──────────────────────────────────────────────────────────
  static const String errorDialogTitle = 'Something went wrong';
  static const String btnRetry         = 'Try Again';
  static const String btnDismiss       = 'Dismiss';
  static const String noInternet = 'No internet connection detected.';

  // Auth Flow
  static const String loginTitle         = 'Welcome Back';
  static const String loginSubtitle      = 'Sign in to continue where you left off.';
  static const String registerTitle      = 'Create your account';
  static const String registerSubtitle   = 'Set up your account to manage your money securely.';
  static const String verifyTitle        = 'Verify your account';
  static const String verifySubtitle     = 'Enter the code sent to your email.';

  // Field Labels
  static const String labelEmail           = 'Email';
  static const String labelPassword        = 'Password';
  static const String labelFullName        = 'Full name';
  static const String labelConfirmPassword = 'Confirm Password';
  static const String labelVerifyCode      = 'Verification code';

  // Placeholders
  static const String hintEmail           = 'you@example.com';
  static const String hintPassword        = 'Enter password';
  static const String hintCreatePassword  = 'Create a strong password';
  static const String hintFullName        = 'As per your official ID';
  static const String hintConfirmPassword = 're-enter your password';
  static const String hintVerifyCode      = 'Enter 6-digit code';

  // Buttons & Links
  static const String btnContinue         = 'Continue';
  static const String btnVerify           = 'Verify';
  static const String btnGoogle           = 'Continue with Google';
  static const String btnApple            = 'Continue with Apple';
  static const String forgotPassword      = 'Forgot password?';
  static const String noAccount           = "Don't have account? ";
  static const String signupLink          = 'Signup';
  static const String hasAccount          = 'Already have account? ';
  static const String loginLink           = 'Login';
  static const String didntReceive        = "Didn't receive it? ";
  static const String resendCode          = 'Resend code';
  static const String orDivider           = 'or';

  // Validation hints
  static const String passwordHint = '8+ characters with letters and numbers';

  // Forgot Password
  static const String forgotTitle          = 'Forgot your password?';
  static const String forgotSubtitle       = 'Enter your email to receive a secure reset link.';
  static const String labelEmailAddress    = 'Email address';
  static const String hintRegisteredEmail  = 'Enter your registered email';
  static const String btnSendResetEmail    = 'Send Reset Email';
  static const String forgotSuccessMsg     = 'Reset link sent! Please check your email.';

  // Reset Password
  static const String resetPasswordTitle    = 'Set a new password';
  static const String resetPasswordSubtitle = 'Choose a strong password for your account.';
  static const String labelNewPassword      = 'New password';
  static const String hintNewPassword       = 'Enter new password';
  static const String labelConfirmNewPass   = 'Confirm new password';
  static const String hintConfirmNewPass    = 'Re-enter new password';
  static const String btnResetPassword      = 'Reset password';
  static const String resetSuccessMsg       = 'Password reset successfully!';

  // Agreement Screen
  static const String agreementTitle     = 'Before You Continue';
  static const String agreementSubtitle  = 'Using Vestie means you accept all of the following guidelines.';
  static const String agreementCheckbox  = 'I have read and accept these guidelines';
  static const List<String> agreementItems = [
    'Users join pots and contribute entirely at their own risk',
    'Vestie does not guarantee the safety or return of any funds',
    'Only send money to people you personally know and trust',
    'Repayment terms and penalties are set by group leaders, not Vestie',
    'All contributions processed through Vestie are final and non-refundable',
  ];

  // State
  static const String loading = 'Loading...';
  static const String emptyData = 'No data available';

  // ── Social Auth ────────────────────────────────────────────────────────────
  static const String socialComingSoon = 'Social sign-in coming soon.';

  // ── Validation Errors ──────────────────────────────────────────────────────
  static const String errorEmailRequired    = 'Email is required.';
  static const String errorEmailInvalid     = 'Enter a valid email address.';
  static const String errorPasswordRequired = 'Password is required.';
  static const String errorPasswordWeak     = 'Password must be 8+ characters with letters and numbers.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorNameRequired     = 'Full name is required.';
  static const String errorOtpInvalid       = 'Please enter a valid 6-digit code.';

  // Onboarding Flow
  static const String onboarding1Title = 'Track everything\nin one place';
  static const String onboarding1Subtitle = 'See your total contributions, active pots, and progress toward shared goals—all in a single view.';
  static const String onboarding2Title = 'Contribute in\nseconds';
  static const String onboarding2Subtitle = 'Add money to your group pot easily. Stay consistent and move closer to your goal together.';
  static const String onboarding3Title = 'Borrow with\napproval';
  static const String onboarding3Subtitle = 'Request funds when needed. Your group reviews and votes, keeping everything fair and transparent.';
  static const String onboardingContinue = 'Continue';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboardingSkip = 'Skip';

  // ── Bottom Navigation ────────────────────────────────────────────────────
  static const String navHome    = 'Home';
  static const String navSearch  = 'Search';
  static const String navAdd     = 'Add';
  static const String navWallet  = 'Wallet';
  static const String navProfile = 'Profile';

  // ── Home Screen ──────────────────────────────────────────────────────────
  static const String totalContributed  = 'Total Contributed';
  static const String myProjects        = 'My Projects';
  static const String joinedProjects    = 'Joined Projects';
  static const String homeEmptyTitle    = 'Start saving together';
  static const String homeEmptySubtitle = 'Create a pot, invite your people,\nreach your goal.';
  static const String btnCreateProject  = 'Create a project';
  static const String btnView           = 'View';
  static const String btnJoin           = 'Join';
  static const String btnSendRequest    = 'Send Request';
  static const String labelGoal         = 'Goal';
  static const String labelRaised       = 'Raised';
  static const String labelTotal        = 'Total';
  static const String labelEndsIn       = 'Ends in';
  static const String statusOnGoing     = 'On Going';
  static const String statusCompleted   = 'Completed';

  // ── Discover Screen ──────────────────────────────────────────────────────
  static const String discoverTitle      = 'Discover';
  static const String discoverSearchHint = 'Search projects, categories, members';
  static const String filterAll          = 'All';
  static const String filterVacations    = 'Vacations';
  static const String filterEmergency    = 'Emergency Fund';
  static const String filterInvestments  = 'Investment';

  // ── Profile Screen ───────────────────────────────────────────────────────
  static const String profileTitle        = 'Profile';
  static const String settingsLabel       = 'Settings';
  static const String menuEditProfile     = 'Edit Profile';
  static const String menuPaymentMethods  = 'Payment Methods';
  static const String menuTransactionHistory = 'Transaction History';
  static const String menuKeyGuidelines   = 'Key Guidelines';
  static const String btnLogout           = 'Logout';

  // ── Edit Profile ─────────────────────────────────────────────────────────
  static const String editProfileTitle    = 'Edit Profile';
  static const String labelFullName2      = 'Full Name';
  static const String labelUsername       = 'Username';
  static const String hintUsername        = '@username';
  static const String btnSaveChanges      = 'Save Changes';

  // ── Payment Methods ──────────────────────────────────────────────────────
  static const String paymentMethodsTitle   = 'Payment Methods';
  static const String emptyPaymentTitle     = 'Add Payment Method';
  static const String emptyPaymentSubtitle  = 'No Payment Method Added. Add method to\ndeposit or contribute';
  static const String btnAddCard            = 'Add Card';
  static const String cardPrimary           = 'Primary';
  static const String setPrimaryLabel       = 'Set as primary payment method';
  static const String setPrimarySubtitle    = 'We will use this payment method for all transactions';
  static const String removeCardLabel       = 'Remove card';
  static const String removeCardSubtitle    = 'We will remove this card from your account';

  // ── Add Card ─────────────────────────────────────────────────────────────
  static const String addCardTitle          = 'Add Card';
  static const String labelCardHolderName   = 'Card Holder Name';
  static const String labelCardNumber       = 'Card Number';
  static const String labelExpiryDate       = 'Expiry Date';
  static const String labelCvv              = 'CVV';
  static const String hintCardHolder        = 'Alex Johnson';
  static const String hintCardNumber        = '0000 0000 0000 0000';
  static const String hintExpiry            = 'MM/YY';
  static const String hintCvv               = '000';
  static const String btnSaveCard           = 'Save Card';
  static const String errCardHolderRequired = 'Card holder name is required';
  static const String errCardNumberRequired = 'Card number is required';
  static const String errCardNumberInvalid  = 'Enter a valid 16-digit card number';
  static const String errExpiryRequired     = 'Expiry date is required';
  static const String errExpiryInvalid      = 'Enter a valid expiry (MM/YY)';
  static const String errExpiryPast         = 'Card expiry date cannot be in the past';
  static const String errCvvRequired        = 'CVV is required';
  static const String errCvvInvalid         = 'CVV must be 3 or 4 digits';

  // ── Transaction History ───────────────────────────────────────────────────
  static const String transactionHistoryTitle = 'Transaction History';
  static const String filterAllTx            = 'All';
  static const String filterDeposits         = 'Deposits';
  static const String filterWithdrawals       = 'Withdrawals';
  static const String filterContributions     = 'Contributions';

  // ── Create Project Wizard ─────────────────────────────────────────────────
  // Amount screen
  static const String projectAmountTitle     = 'Project Amount';
  static const String projectAmountSubtitle  = 'How much you want to save?';

  // Step 1 – Details
  static const String createDetailsTitle     = 'Project Details';
  static const String labelProjectName       = 'Project Name';
  static const String hintProjectName        = 'Family Vacations';
  static const String labelProjectDesc       = 'Description';
  static const String hintProjectDesc        = 'A shared goal for flights, hotels and activities.';
  static const String labelCategory          = 'Category';
  static const String labelDeadline          = 'Deadline';
  static const String labelVisibility        = 'Visibility';
  static const String visibilityPublic       = 'Public';
  static const String visibilityPrivate      = 'Private';

  // Category options
  static const String catVacation            = 'Vacation';
  static const String catEmergency           = 'Emergency';
  static const String catInvestment          = 'Investment';
  static const String catOther               = 'Other';

  // Step 2 – Borrowing
  static const String createBorrowingTitle   = 'Borrowing';
  static const String labelRoi               = 'ROI (optional)';
  static const String roiHint                = '5%';
  static const String roiSubtitle            = 'Set this to incentivize contributors. Paid out on project close.';
  static const String labelEnableBorrowing   = 'Enable borrowing for members?';
  static const String labelBorrowLimit       = 'Default borrow limit per member';
  static const String labelRepaymentWindow   = 'Repayment window (days)';
  static const String labelPenalty           = 'Penalty (%)';
  static const String btnNext                = 'Next';

  // Step 3 – Review
  static const String createReviewTitle      = 'Review';
  static const String reviewSectionDetails   = 'Project Details';
  static const String reviewSectionDescRules = 'Description & Rules';
  static const String reviewSectionBorrowing = 'Borrowing';
  static const String reviewSectionRoi       = 'ROI';
  static const String btnEdit                = 'Edit';
  static const String btnCreateProject2      = 'Create Project';
  static const String reviewRoiNotSet        = 'Not set';

  // Success
  static const String projectCreatedTitle    = 'Project Created';
  static const String shareViaWhatsapp       = 'Share via Whatsapp';
  static const String btnGoToMyProject       = 'Go to my Project';
  static const String linkCopied             = 'Link copied!';
  static const String shareBaseDomain        = 'vestie.app/join';
  static const String shareWhatsappPrefix    = 'Join my project: https://';

  // ── Review screen row labels ──────────────────────────────────────────────
  static const String reviewLabelName        = 'Name';
  static const String reviewLabelGoal        = 'Goal';
  static const String reviewLabelDeadline    = 'Deadline';
  static const String reviewLabelCategory    = 'Category';
  static const String reviewLabelDescription = 'Description';
  static const String reviewLabelVisibility  = 'Visibility';
  static const String reviewLabelType        = 'Type';
  static const String reviewLabelLimit       = 'Limit';
  static const String reviewLabelWindow      = 'Window';
  static const String reviewLabelPenalty     = 'Penalty';
  static const String reviewValuePublic      = 'Public';
  static const String reviewValuePrivate     = 'Private';
  static const String reviewValueEnabled     = 'Enabled';
  static const String reviewValueDisabled    = 'Disabled';
  static const String reviewValueDays        = 'days';

  // ── Form placeholders & hints ─────────────────────────────────────────────
  static const String deadlinePlaceholder    = 'MM/DD/YYYY';
  static const String hintBorrowLimit        = '250';
  static const String hintRepaymentWindow    = '30';
  static const String hintPenalty            = '20';

  // ── Validation errors — Create Project ───────────────────────────────────
  static const String errProjectNameRequired = 'Project name is required';
  static const String errProjectNameShort    = 'At least 3 characters required';
  static const String errDescRequired        = 'Description is required';
  static const String errDeadlineRequired    = 'Deadline is required';
  static const String errBorrowLimitRequired = 'Borrow limit is required';
  static const String errBorrowLimitInvalid  = 'Enter a valid amount';
  static const String errWindowRequired      = 'Repayment window is required';
  static const String errWindowInvalid       = 'Enter a valid number of days';
  static const String errPenaltyRequired     = 'Penalty is required';
  static const String errPenaltyInvalid      = 'Enter a value between 0–100';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String takePhoto             = 'Take Photo';
  static const String chooseFromGallery     = 'Choose from Gallery';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
  static const String cardSavedSuccess      = 'Card saved successfully!';
  static const String cardRemovedSuccess    = 'Card removed.';

  // ── Router / placeholder stubs ────────────────────────────────────────────
  static const String keyGuidelinesComingSoon = 'Key Guidelines — Coming Soon';
  static const String routeNotFound           = 'Route Not Found';

  // ── Wallet ───────────────────────────────────────────────────────────────
  static const String walletTitle              = 'Wallet';
  static const String walletAmountLabel        = 'Wallet Amount';
  static const String btnDepositFunds          = 'Deposit funds';
  static const String btnWithdrawFunds          = 'Withdraw funds';
  static const String depositFundsTitle         = 'Deposit';
  static const String withdrawFundsTitle        = 'Withdraw';
  static const String depositAmountSubtitle     = 'Enter amount to deposit';
  static const String withdrawAmountSubtitle    = 'Enter amount to withdraw';
  static const String confirmDepositTitle       = 'Confirm Deposit';
  static const String confirmWithdrawTitle      = 'Confirm Withdraw';
  static const String walletDepositDetailsTitle = 'Deposit Details';
  static const String walletWithdrawDetailsTitle = 'Withdraw Details';
  static const String walletDepositingLabel     = 'Depositing';
  static const String walletWithdrawingLabel    = 'Withdrawing';
  static const String walletMethodLabel         = 'Method';
  static const String walletToLabel             = 'To';
  static const String walletDepositFeeLabel     = 'Deposit fee';
  static const String walletWithdrawalFeeLabel  = 'Withdrawal fee';
  static const String walletProcessingTimeLabel = 'Processing time';
  static const String walletProcessingTimeValue = '1-3 business days';
  static const String walletNewBalanceAfterLabel = 'New balance after';
  static const String walletFeeNone             = 'None';
  static const String labelAmount               = 'Amount';
  static const String labelFee                  = 'Fee';
  static const String labelFrom                 = 'From';
  static const String labelTo                   = 'To';
  static const String btnConfirm                = 'Confirm';
  static const String btnDone                   = 'Done';
  static const String depositSuccessTitle       = 'Deposit Successful';
  static const String depositAddedPrefix        = ' has been added to';
  static const String depositAddedLineTwo       = 'your wallet.';
  static const String withdrawSuccessTitle      = 'Withdrawal Requested';
  static const String withdrawEtaPrefix         = 'Your ';
  static const String withdrawEtaSuffix         = ' will arrive in 1-3';
  static const String withdrawEtaLineTwo        = 'business days.';
  static const String repaySentSuccessTitle     = 'Repay Sent Successfully';
  static const String repaySentPrefix           = 'You’ve sent repay amount of ';
  static const String repaySentSuffix           = ' to';
  static const String contributionSuccessTitle  = 'Contribution Successful';
  static const String btnBackToWallet           = 'Back to Wallet';
  static const String addAmount               = 'Add Amount';
  // ── Recent Activity ───────────────────────────────────────────────────────
  static const String borrowedLabel             = 'Borrowed';
  static const String recentActivityHeader     = 'Recent Activity';
  static const String txWalletDeposit           = 'Wallet Deposit';
  static const String txContributionPrefix      = 'Contribution: ';
  static const String txBorrowPrefix            = 'Borrow: ';

  // ── Project Detail ────────────────────────────────────────────────────────
  static const String projectDetailTitle        = 'Project';
  static const String announcementTitle         = 'Announcement';
  static const String announcementPlaceholder   = 'Any announcement will come up here';
  static const String noMoreContributionTitle   = 'No More Contributon';
  static const String noMoreContributionBody    = 'You can no longer contribute to this investment as leader has closed this project, leader will come back soon to fund your amount and ROI/profit.';
  static const String btnContribute             = 'Contribute';
  static const String btnBorrow                 = 'Borrow';
  static const String tabBorrowRequests         = 'Borrow Requests';
  static const String tabMembers                = 'Members';
  static const String tabMember                 = 'Member';
  static const String tabManageMembers          = 'Manage Members';
  static const String labelContributedWithColon = 'Contributed: ';
  static const String overdueLabel              = 'Overdue';
  static const String requestedAmount           = 'Requested Amount';
  static const String viewAllRequests           = 'View All Requests';
  static const String borrowRequestsTitle       = 'Borrow Requests';
  static const String upvoteLabel               = 'Upvote';
  static const String downvoteLabel             = 'Downvote';
  static const String upvotedStatusLabel        = 'You’ve Upvoted this Requested';
  static const String downvotedStatusLabel      = 'You’ve Downvote this Requested';
  static const String acceptLabel               = 'Accept';
  static const String rejectLabel               = 'Reject';
  static const String educationLoan             = 'Education Loan';
  static const String goalPrefix                = 'Goal ';
  static const String memberProfileSuffix       = ' Profile';
  static const String contributedLabel          = 'Contributed';
  static const String contributionsLabel        = 'Contributions';
  static const String borrowedLabelShort        = 'Borrowed';
  static const String btnMakeCoLeader           = 'Make Co-Leader';
  static const String btnRemoveCoLeader         = 'Remove Role';
  static const String btnTakeAction             = 'Take Action';
  static const String btnRemoveMember           = 'Remove Member';
  static const String overdueBorrowNotice       = 'This User has 1 overdue borrow.';
  static const String penaltyActionTitle        = 'Penalty Action';
  static const String markAsDefaulted           = 'Mark as Defaulted';
  static const String removeMemberConfirmTitle  = 'Remove Member?';
  static const String removeMemberConfirmBody   = 'Are you sure you want to remove this member? This action cannot be undone.';
  static const String markDefaultedConfirmTitle = 'Mark as Defaulted';
  static const String markDefaultedConfirmBody  = 'Marking a user as defaulted blocks them from contributing or borrowing in any group until all dues are cleared.';
  static const String makeCoLeaderConfirmTitle  = 'Make Co-Leader?';
  static const String makeCoLeaderConfirmBody   = 'This user will be able to approve borrow requests, post announcements, and manage members. You will remain the main leader.';
  static const String removeCoLeaderConfirmTitle = 'Remove Co-Leader?';
  static const String removeCoLeaderConfirmBody  = 'This user will return to a regular member and lose the ability to approve requests and manage the group.';
  static const String coLeaderAssignedTitle     = 'Co-Leader Assigned';
  static const String coLeaderAssignedBody      = 'User is now Co-Leader and can approve requests and manage members.';
  static const String coLeaderRemovedTitle      = 'Co-Leader Removed';
  static const String coLeaderRemovedBody       = 'User is now a regular member.';
  static const String btnRemove                 = 'Remove';
  static const String btnCancel                 = 'Cancel';
  static const String btnOk                     = 'Ok';
  static const String btnNo                     = 'No';
  static const String penaltyBorrowedLabel      = 'Borrowed';
  static const String penaltyDueLabel           = 'Due';
  static const String penaltyOverdueLabel       = 'Overdue';
  static const String penaltyPenaltyLabel       = 'Penalty';
  static const String penaltyTotalOwedLabel     = 'Total owed';
  static const String penaltyBorrowedAmount     = '\$250';
  static const String penaltyDueDateValue       = 'Apr 1, 2025';
  static const String penaltyOverdueValue       = '15 days';
  static const String penaltyChargeValue        = '\$20.00';
  static const String penaltyTotalOwedValue     = '\$220.00';
  static const String memberTxDateMar11         = 'Mar 11';
  static const String memberTxDateMar12         = 'Mar 12';
  static const String approveBorrowRequestTitle = 'Approve Borrow Request?';
  static const String rejectBorrowRequestTitle  = 'Reject Borrow Request';
  static const String borrowApprovedTitle       = 'Approve Borrow Request?';
  static const String borrowRejectedTitle       = 'Borrow Request Rejected';
  static const String approveLabel              = 'Approve';
  static const String rejectShortLabel          = 'Reject';

  static String borrowRequestActionDescription({
    required bool isApprove,
    required String memberName,
    required String amount,
  }) {
    final action = isApprove ? 'approving' : 'rejecting';
    return 'You’re $action borrow request\nfrom $memberName of \$$amount';
  }

  // ── Leader Project Actions ────────────────────────────────────────────────
  static const String menuJoinRequests          = 'Join Requests';
  static const String menuAddAnnouncement       = 'Add Announcement';
  static const String menuEditProject           = 'Edit Project';
  static const String menuInviteMembers         = 'Invite Members';
  static const String menuMarkSuccessful        = 'Mark as Successful';
  static const String menuCancelProject         = 'Cancel Project';
  static const String hintAnnouncementText      = 'Type your announcement...';
  static const String deleteAnnouncementLabel   = 'Delete announcement';
  static const String createAnnouncementTitle   = 'Create Announcement';
  static const String announcementHeadingLabel  = 'Announcement Heading';
  static const String announcementContentLabel  = 'Announcement Content';
  static const String announcementHeadingHint   = 'Deposit Issued';
  static const String announcementContentHint   = 'Good News, Your deposit has been issued';
  static const String announcementAutoRemoveNote = 'Announcement will auto remove after 24 hours';
  static const String btnCreateAnnouncement     = 'Create Announcement';
  static const String joinRequestApprovedTitle  = 'Join Request Approved';
  static const String joinRequestDeclinedTitle  = 'Join Request Declined';
  static const String joinRequestApproveLabel   = 'Accept';
  static const String joinRequestDeclineLabel   = 'Decline';
  static const String shareQrCode               = 'Share QR Code';
  static const String copyCodeFromBelow         = 'Or copy code from below';
  static const String inviteLinkSample          = 'vestie.app/join/family-vacation-2025';

  static String joinRequestApprovedDescription(String memberName) =>
      'You’ve approved the join request from $memberName';

  static String joinRequestDeclinedDescription(String memberName) =>
      'You’ve declined the join request from $memberName';

  static String removeMemberTitle(String memberName) => 'Remove $memberName';

  static String removeMemberBody(String memberName) =>
      'Are you sure you want to remove $memberName? This action cannot be undone.';

  static String makeCoLeaderDescription(String memberName) =>
      '$memberName will be able to approve borrow requests, post announcements, and manage members. You\'ll remain the main leader.';

  static String removeCoLeaderDescription(String memberName) =>
      '$memberName will return to a regular member. They will lose the ability to approve requests and manage the group.';

  static String coLeaderAssignedDescription(String memberName, String projectName) =>
      '$memberName is now Co-Leader of $projectName. They can approve requests and manage members.';

  static String coLeaderRemovedDescription(String memberName, String projectName) =>
      '$memberName is now a regular member of $projectName.';

  static String borrowApprovePrefix() =>
      'You’re approving borrow request from ';

  static String borrowRejectPrefix() =>
      'You’re rejecting borrow request from ';
}
