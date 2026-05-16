class AppAssets {
  AppAssets._();

  static const String _imagePath = 'assets/images';
  static const String _iconPath  = 'assets/icons';

  // ── Images ────────────────────────────────────────────────────────────────
  static const String logoSvg = '$_imagePath/logo.svg';
  static const String appGradient = '$_imagePath/gradient.png';
  static const String authLoginGradient = '$_imagePath/Login gradient.svg';
  /// Auth screens background — purple-to-white gradient PNG.
  static const String authGradientBg = '$_imagePath/auth_gradient_bg.png';
  static const String splashBackground = '$_imagePath/splash_background.png';
  /// Risk / agreement screen hero (`agreement_icon.svg` — triangle + “i” on soft circle).
  static const String agreementIcon = '$_imagePath/agreement_icon.svg';

  /// Home + Discover empty state — full-screen purple→white gradient background.
  static const String emptyStateBackground =
      '$_imagePath/empty_state_background.png';
  /// Home + Discover empty state — 3D target / dart (PNG).
  static const String homeDiscoverEmptyState =
      '$_imagePath/home_discover_empty_state.png';
  /// Legacy SVG empty illustration (unused in UI; kept for reference).
  static const String dashboardEmptyStateSvg =
      '$_imagePath/dashboard_empty_state_image.svg';
  static const String homeEmptyState = homeDiscoverEmptyState;
  static const String discoverEmptyIllustration = homeDiscoverEmptyState;
  static const String emptyNotification    = '$_imagePath/emptynotification.png';

  /// Project detail — no borrow requests (Figma 3D person + $).
  static const String borrowRequestsEmptyState =
      '$_imagePath/borrow_requests_empty_state.png';

  // Project created success illustration (PNG — reliable rendering across devices).
  static const String projectCreatedImage = '$_imagePath/project_created_image.png';
  /// 3D purple “success” badge (member flows: join approved, vote yes, mark complete).
  static const String markSuccessfullProject = '$_imagePath/markSuccessfullProject.png';
  static const String markCancel            = '$_imagePath/markcancel.png';

  // Onboarding
  static const String onboarding1 = '$_imagePath/onboarding_1.png';
  static const String onboarding2 = '$_imagePath/onboarding_2.png';
  static const String onboarding3 = '$_imagePath/onboarding_3.png';
  static const String inviteQrCode = '$_imagePath/qrcode.png';

  // ── Auth Social Icons ─────────────────────────────────────────────────────
  static const String iconApple  = '$_iconPath/apple.svg';
  static const String iconGoogle = '$_iconPath/gmail.svg';
  /// Register password hint met state — green circle + white check (design PNG).
  static const String passwordRequirementMetIcon =
      '$_iconPath/password_requirement_met.png';

  // Header / system
  static const String iconNotification = '$_iconPath/notification-01.svg';
  /// Home / Discover header — favourite (VFF hub), design `favourite.svg`.
  static const String iconFavourite = '$_iconPath/favourite.svg';
  /// List row graphic (notification item, design export “Frame 258”).
  static const String notificationRowIcon = '$_iconPath/Frame 258.png';

  // ── Bottom Navigation Icons ───────────────────────────────────────────────
  static const String iconHome    = '$_iconPath/home_icon.svg';
  static const String iconSearch  = '$_iconPath/search_icon.svg';
  static const String iconAdd     = '$_iconPath/add_icon.svg';
  static const String iconWallet  = '$_iconPath/wallet_icon.svg';
  static const String iconProfile = '$_iconPath/profile_icon.svg';

  // ── Profile Settings Icons ────────────────────────────────────────────────
  static const String iconEditProfile       = '$_iconPath/edit_profile_icon.svg';
  static const String iconPaymentMethods    = '$_iconPath/payment_methods_icon.svg';
  static const String iconTransactionHistory = '$_iconPath/transactionhistory_icon.svg';
  static const String iconKeyGuidelines     = '$_iconPath/guidelines_icons.svg'; //
  /// Profile avatar — tap to change photo (design `Frame 343.svg`).
  static const String profileAvatarEditBadge = '$_iconPath/Frame 343.svg';
  static const String emptyPaymentMethodIcon     = '$_iconPath/wallet-cards.svg';
  /// Wallet “Recent Activity” empty — stacked cards motif.
  static const String walletEmptyActivityIllustration = emptyPaymentMethodIcon;
  // ── Payment Card Brand Logos ──────────────────────────────────────────────
  static const String iconVisa       = '$_iconPath/visacard_icon.svg';
  static const String iconMastercard = '$_iconPath/mastercard_icon.svg';

  // ── Transaction Type Icons ────────────────────────────────────────────────
  static const String iconDeposit      = '$_iconPath/deposit_icon.svg';
  static const String iconContribution = '$_iconPath/contribution_icon.svg';
  static const String iconDollarCircle = '$_iconPath/dollar-circle.svg';
  static const String iconCircleArrowUp02 = '$_iconPath/circle-arrow-up-02.svg';

  // ── Voting Icons ─────────────────────────────────────────────────────────
  static const String iconThumbsUp   = '$_iconPath/thumbs-up.svg';
  static const String iconThumbsDown = '$_iconPath/thumbs-down.svg';

  // ── Arrow Direction Icons ────────────────────────────────────────────────
  static const String iconArrowUpBig   = '$_iconPath/arrow-up-big.svg';
  static const String iconArrowDownBig = '$_iconPath/arrow-down-big.svg';
  static const String iconPopMenu      = '$_iconPath/popmenuicon.svg';
  /// Member “Project Actions” — funds history & leave project rows.
  static const String iconProjectFundHistory = '$_iconPath/project_fund_history.svg';
  static const String iconLeaveGroup = '$_iconPath/leave-group.svg';
  static const String iconEmergencyFund = '$_iconPath/emergency fund.svg';
  static const String iconInvestmentFund = '$_iconPath/investment  icon.svg';

  // ── Leader Project Action Icons ───────────────────────────────────────────
  static const String iconJoinRequest      = '$_iconPath/join-request.svg';
  static const String iconAddAnnouncement  = '$_iconPath/add announcement.svg';
  static const String iconEditProject      = '$_iconPath/edit project.svg';
  static const String iconMarkSuccessful   = '$_iconPath/mark successfull.svg';
  static const String iconCancelProject    = '$_iconPath/cancel project.svg';
  /// Invite members / empty-state “add” — simple + (24×24, tints with primary).
  static const String plusSign = '$_iconPath/plus-sign.svg';
  static const String checkMarkSuccessful    = '$_iconPath/checkmark-circle-02.svg'; //
  /// [AppTickSwitch] selected state — purple tile + white check (design PNG).
  static const String iconTickSwitchOn = '$_iconPath/tick_switch_on.png';
  static const String infoIcon    = '$_iconPath/alert-01.svg';
  // ── Specific Feature Backgrounds ──────────────────────────────────────────
  static const String contributionSuccessBg = '$_imagePath/Contribution Successful.png';
  static const String failureIcon           = '$_imagePath/failure_icon.png';
  static const String upWordArrow    = '$_iconPath/arrow-up-big.svg';
  static const String downWordArrow    = '$_iconPath/arrow-down-big.svg';
  static const String crown    = '$_iconPath/crown.svg';

  // ── UI glyphs (replace Material Icons; stroke icons tint via ColorFilter) ─
  static const String iconArrowBack = '$_iconPath/arrow_back.png';
  static const String iconChevronRight = '$_iconPath/icon_chevron_right.svg';
  static const String iconClose = '$_iconPath/icon_close.svg';
  /// Create project amount sheet — dismiss (design `cross-icon.svg`).
  static const String iconCreateProjectSheetClose = '$_iconPath/cross_icon.svg';
  /// Generic heart glyph (lists, empty states); headers use [iconFavourite].
  static const String iconHeart = '$_iconPath/icon_heart.svg';
  static const String iconChevronDown = '$_iconPath/icon_chevron_down.svg';
  static const String iconCopy = '$_iconPath/icon_copy.svg';
  static const String iconVisibility = '$_iconPath/icon_visibility.svg';
  static const String iconVisibilityOff = '$_iconPath/icon_visibility_off.svg';
  /// Login / auth password “hidden” state — design PNG (closed eye), crisp at small sizes.
  static const String iconPasswordHiddenEye = '$_iconPath/password_eye_hidden.png';
  static const String iconBackspace = '$_iconPath/icon_backspace.svg';
  static const String iconCalendar = '$_iconPath/icon_calendar.svg';
  /// Project card “Ends in” row — `calendar-02` (12×12 in UI).
  static const String iconCalendar02 = '$_iconPath/calendar_02.svg';
  static const String iconSchedule = '$_iconPath/icon_schedule.svg';
  static const String iconGroups = '$_iconPath/icon_groups.svg';
  static const String iconShield = '$_iconPath/icon_shield.svg';
  static const String iconPeople = '$_iconPath/icon_people.svg';
  static const String iconPerson = '$_iconPath/icon_person.svg';
  /// Leader badge on project member rows (Figma `user-02.svg`).
  static const String iconLeaderUser = '$_iconPath/user-02.svg';
  /// My Borrows — project overflow menu (`user-dollar.svg`).
  static const String iconMyBorrows = '$_iconPath/user-dollar.svg';
  static const String iconSettings = '$_iconPath/icon_settings.svg';
  static const String iconDelete = '$_iconPath/icon_delete.svg';
  static const String iconInfo = '$_iconPath/icon_info.svg';
  /// Information circle (design export `information-circle.svg`).
  static const String iconInformationCircle = '$_iconPath/information_circle.svg';
  static const String iconCamera = '$_iconPath/icon_camera.svg';
  static const String iconPhotoLibrary = '$_iconPath/icon_photo_library.svg';
  static const String iconChat = '$_iconPath/icon_chat.svg';
  static const String iconLink = '$_iconPath/icon_link.svg';
  static const String iconFacebook = '$_iconPath/icon_facebook.svg';
  static const String iconInstagram = '$_iconPath/icon_instagram.svg';
  static const String iconRadioOn = '$_iconPath/icon_radio_on.svg';
  static const String iconRadioOff = '$_iconPath/icon_radio_off.svg';
  static const String iconList = '$_iconPath/icon_list.svg';
  static const String iconLightning = '$_iconPath/icon_lightning.svg';
}
