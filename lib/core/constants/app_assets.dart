class AppAssets {
  AppAssets._();

  static const String _imagePath = 'assets/images';
  static const String _iconPath = 'assets/icons';

  // ── Images ────────────────────────────────────────────────────────────────
  // Splash
  static const String splashLogo = '$_imagePath/splash_logo.svg';
  static const String splashBackground = '$_imagePath/splash_background.png';

  // Auth
  /// Auth screens background — purple-to-white gradient PNG.
  static const String authGradientBg = '$_imagePath/auth_gradient_bg.png';

  /// Risk / agreement screen hero — triangle + “i” on soft circle.
  static const String authAgreementHero = '$_imagePath/auth_agreement_hero.svg';

  // Header / screen backgrounds
  /// Home header + post-auth screens — purple→white gradient strip.
  static const String headerGradient = '$_imagePath/header_gradient.png';

  /// Success screens + Home/Discover empty — full-screen purple→white gradient.
  static const String successScreenBackground =
      '$_imagePath/success_screen_background.png';

  /// VFF peer profile + project invitation — purple→white gradient.
  static const String vffProfileBackground =
      '$_imagePath/vff_profile_background.png';

  // Home / Discover
  /// Home + Discover empty state — 3D target / dart.
  static const String homeDiscoverEmpty = '$_imagePath/home_discover_empty.png';

  /// Home / Discover project cards — right of subtitle (100×69).
  static const String cardInvestment = '$_imagePath/card_investment.png';
  static const String cardEmergency = '$_imagePath/card_emergency.png';
  static const String cardVacation = '$_imagePath/card_vacation.png';

  // Notifications
  static const String notificationsEmpty =
      '$_imagePath/notifications_empty.png';

  /// Wallet recent activity empty — 3D glass coin with $.
  static const String walletEmpty = '$_imagePath/wallet_empty.png';

  // Project detail empty states
  /// Borrow / join requests lists — 3D person + $.
  static const String borrowRequestsEmpty =
      '$_imagePath/borrow_requests_empty.png';

  // Success / status heroes
  /// Default success screen + dialog hero (project created, vote passed, etc.).
  static const String successProjectCreated =
      '$_imagePath/success_project_created.png';

  /// VFF invites sent — same purple badge hero as [successProjectCreated].
  static const String successProjectJoined = successProjectCreated;

  /// Shared-link invitation — 3D glass person + plus ring.
  static const String inviteProjectHero = '$_imagePath/invite_project_hero.png';

  /// Mark project successful flow — 3D green success badge.
  static const String markProjectSuccess =
      '$_imagePath/mark_project_success.png';

  /// Cancel project + delete account warning hero.
  static const String statusCancelWarning =
      '$_imagePath/status_cancel_warning.png';

  /// Failure dialogs + leave/vote-failed screens — red X badge.
  static const String statusFailure = '$_imagePath/status_failure.png';

  // Onboarding
  static const String onboardingStep1 = '$_imagePath/onboarding_step_1.png';
  static const String onboardingStep2 = '$_imagePath/onboarding_step_2.png';
  static const String onboardingStep3 = '$_imagePath/onboarding_step_3.png';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String authApple = '$_iconPath/auth_apple.svg';
  static const String authGoogle = '$_iconPath/auth_google.svg';

  /// Register password hint met state — green circle + white check (design PNG).
  static const String authPasswordMet = '$_iconPath/auth_password_met.png';
  static const String authPasswordVisible =
      '$_iconPath/auth_password_visible.svg';

  /// Login / auth password “hidden” state — design PNG (closed eye), crisp at small sizes.
  static const String authPasswordHidden =
      '$_iconPath/auth_password_hidden.png';

  // ── Header ────────────────────────────────────────────────────────────────
  static const String headerNotification = '$_iconPath/header_notification.svg';

  /// Home / Discover header — VFF hub entry.
  static const String headerVffHub = '$_iconPath/header_vff_hub.svg';

  /// Overflow / more-options menu trigger (three dots).
  static const String iconMoreOptions = '$_iconPath/icon_more_options.svg';

  /// Notifications list row graphic.
  static const String notificationRowIcon =
      '$_iconPath/notification_row_icon.png';

  // ── Bottom navigation ─────────────────────────────────────────────────────
  static const String navHome = '$_iconPath/nav_home.svg';
  static const String navHomeActive = '$_iconPath/nav_home_active.svg';
  static const String navDiscover = '$_iconPath/nav_discover.svg';
  static const String navAdd = '$_iconPath/nav_add.svg';
  static const String navWallet = '$_iconPath/nav_wallet.svg';
  static const String navProfile = '$_iconPath/nav_profile.svg';
  static const String navDiscoverActive = '$_iconPath/nav_discover_active.svg';
  static const String navWalletActive = '$_iconPath/nav_wallet_active.svg';
  static const String navProfileActive = '$_iconPath/nav_profile_active.svg';

  // ── Profile settings ──────────────────────────────────────────────────────
  static const String profilePaymentMethods =
      '$_iconPath/profile_payment_methods.svg';
  static const String profileCompletedProjects =
      '$_iconPath/profile_completed_projects.svg';
  static const String profileGuidelines = '$_iconPath/profile_guidelines.svg';

  /// Profile avatar — tap to change photo.
  static const String profileAvatarEditBadge =
      '$_iconPath/profile_avatar_edit_badge.svg';
  static const String profileCamera = '$_iconPath/profile_camera.svg';
  static const String profilePhotoLibrary =
      '$_iconPath/profile_photo_library.svg';

  /// Payment methods empty — 3D card holder.
  static const String profilePaymentMethodsEmpty =
      '$_imagePath/profile_payment_methods_empty.png';

  /// Payment card detail bottom sheet background base.
  static const String paymentCardBgBase =
      '$_imagePath/payment_card_bg_base.png';

  /// Payment card detail bottom sheet top overlay.
  static const String paymentCardBgOverlay =
      '$_imagePath/payment_card_bg_overlay.png';

  // Wallet withdraw
  static const String walletWithdrawStandard =
      '$_imagePath/wallet_withdraw_standard.png';
  static const String walletWithdrawInstant =
      '$_imagePath/wallet_withdraw_instant.png';

  // ── Payment card brands ───────────────────────────────────────────────────
  static const String paymentVisa = '$_iconPath/payment_visa.svg';
  static const String paymentMastercard = '$_iconPath/payment_mastercard.svg';

  // ── Wallet / transaction history ──────────────────────────────────────────
  static const String transactionDeposit = '$_iconPath/transaction_deposit.svg';
  static const String transactionContribution =
      '$_iconPath/transaction_contribution.svg';
  static const String transactionBorrow = '$_iconPath/transaction_borrow.svg';
  static const String iconDollarCircle = '$_iconPath/icon_dollar_circle.svg';
  static const String transactionTransferOut =
      '$_iconPath/transaction_transfer_out.svg';
  static const String walletPaymentChevron =
      '$_iconPath/wallet_payment_chevron.svg';

  // ── Voting ──────────────────────────────────────────────────────────────────
  static const String voteThumbsUp = '$_iconPath/vote_thumbs_up.svg';
  static const String voteThumbsDown = '$_iconPath/vote_thumbs_down.svg';
  static const String voteArrowUp = '$_iconPath/vote_arrow_up.svg';
  static const String voteArrowDown = '$_iconPath/vote_arrow_down.svg';

  // ── Project type (Discover filters + card chips) ────────────────────────────
  static const String projectTypeVacation =
      '$_iconPath/project_type_vacation.svg';
  static const String projectTypeEmergency =
      '$_iconPath/project_type_emergency.svg';
  static const String projectTypeInvestment =
      '$_iconPath/project_type_investment.svg';

  // ── Leader project actions menu ─────────────────────────────────────────────
  static const String leaderJoinRequests =
      '$_iconPath/leader_join_requests.svg';
  static const String leaderAddAnnouncement =
      '$_iconPath/leader_add_announcement.svg';
  static const String leaderEditProject = '$_iconPath/leader_edit_project.svg';
  static const String leaderMarkSuccessful =
      '$_iconPath/leader_mark_successful.svg';
  static const String leaderStopContributions =
      '$_iconPath/leader_stop_contributions.svg';
  static const String leaderCancelProject =
      '$_iconPath/leader_cancel_project.svg';

  // ── Member project actions menu ───────────────────────────────────────────
  static const String memberFundsHistory =
      '$_iconPath/member_funds_history.svg';
  static const String memberLeaveProject =
      '$_iconPath/member_leave_project.svg';

  /// My Borrows — project overflow menu.
  static const String myBorrowsMenu = '$_iconPath/my_borrows_menu.svg';

  // ── VFF ───────────────────────────────────────────────────────────────────
  /// Invite VFF grid — selected avatar badge.
  static const String vffFriendSelected = '$_iconPath/vff_friend_selected.svg';

  // ── Project detail / cards ──────────────────────────────────────────────────
  static const String projectCardCalendar =
      '$_iconPath/project_card_calendar.svg';
  static const String projectMembers = '$_iconPath/project_members.svg';

  /// Leader badge on project member rows.
  static const String badgeLeader = '$_iconPath/badge_leader.svg';

  /// Co-leader badge on project member rows.
  static const String badgeCoLeader = '$_iconPath/badge_co_leader.svg';
  static const String badgeLeaderCrown = '$_iconPath/badge_leader_crown.svg';

  // ── Create project ────────────────────────────────────────────────────────
  static const String createProjectCalendar =
      '$_iconPath/create_project_calendar.svg';
  static const String sheetClose = '$_iconPath/sheet_close.svg';

  // ── Share / invite ────────────────────────────────────────────────────────
  /// Invite members / empty-state add — simple + (24×24, tints with primary).
  static const String iconAdd = '$_iconPath/icon_add.svg';
  static const String shareChat = '$_iconPath/share_chat.svg';
  static const String shareLink = '$_iconPath/share_link.svg';
  static const String shareFacebook = '$_iconPath/share_facebook.svg';
  static const String shareInstagram = '$_iconPath/share_instagram.svg';

  // ── Shared UI glyphs ──────────────────────────────────────────────────────
  static const String iconCheckCircle = '$_iconPath/icon_check_circle.svg';

  /// [AppTickSwitch] selected state — purple tile + white check (design PNG).
  static const String iconTickSwitchOn = '$_iconPath/icon_tick_switch_on.png';
  static const String iconAlertTriangle = '$_iconPath/icon_alert_triangle.svg';
  static const String iconArrowBack = '$_iconPath/icon_arrow_back.png';
  static const String iconChevronRight = '$_iconPath/icon_chevron_right.svg';
  static const String iconClose = '$_iconPath/icon_close.svg';
  static const String iconChevronDown = '$_iconPath/icon_chevron_down.svg';
  static const String iconCopy = '$_iconPath/icon_copy.svg';
  static const String iconBackspace = '$_iconPath/icon_backspace.svg';
  static const String iconPerson = '$_iconPath/icon_person.svg';
  static const String iconDelete = '$_iconPath/icon_delete.svg';
  static const String iconInfo = '$_iconPath/icon_info.svg';
  static const String iconInfoCircle = '$_iconPath/icon_info_circle.svg';
}
