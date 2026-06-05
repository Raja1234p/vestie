import 'package:flutter/material.dart';

/// Centralized color palette.
/// Every raw value comes directly from the official Figma token sheets.
/// Semantic tokens (used in widgets) reference scale constants below.
class AppColors {
  AppColors._();

  // ════════════════════════════════════════════════════════════════════════════
  // FIGMA DESIGN-TOKEN SCALES
  // ════════════════════════════════════════════════════════════════════════════

  // ── Purple ──────────────────────────────────────────────────────────────────
  static const Color purple100  = Color(0xFFF5F0FE);
  static const Color purple200  = Color(0xFFEBE1FD);
  static const Color purple300  = Color(0xFFDDD0FC);
  static const Color purple400  = Color(0xFFCEBEFB);
  static const Color purple500  = Color(0xFFB098F5);
  static const Color purple600  = Color(0xFF9268EC);
  static const Color purple700  = Color(0xFF7A3FE0);
  static const Color purple800  = Color(0xFF6230C2);
  static const Color purple900  = Color(0xFF4C24A0);
  static const Color purple1000 = Color(0xFF381A7A);
  static const Color purple1100 = Color(0xFF241055);

  // ── Grey ────────────────────────────────────────────────────────────────────
  static const Color grey100  = Color(0xFFF8F7FA);
  static const Color grey200  = Color(0xFFEFECF5);
  static const Color grey300  = Color(0xFFE4E0EE);
  static const Color grey400  = Color(0xFFD5D0E6);
  static const Color grey500  = Color(0xFFB8B2D1);
  static const Color grey600  = Color(0xFF9990BB);
  static const Color grey700  = Color(0xFF7B73A3);
  static const Color grey800  = Color(0xFF5E5783);
  static const Color grey900  = Color(0xFF443F63);
  static const Color grey1000 = Color(0xFF2D2850);
  static const Color grey1100 = Color(0xFF1A1630);
  static const Color grey1200 = Color(0xFF0E0C1C);

  // ── Red ─────────────────────────────────────────────────────────────────────
  static const Color red100  = Color(0xFFFEF2F2);
  static const Color red200  = Color(0xFFFDE3E3);
  static const Color red300  = Color(0xFFFBD0D0);
  /// Remove menu drop shadow base (Figma #D09292 @ 20%).
  static const Color vffRemoveOverlayShadow = Color(0xFFD09292);
  static const Color red400  = Color(0xFFF8B8B8);
  static const Color red500  = Color(0xFFF38C8C);
  static const Color red600  = Color(0xFFEB6060);
  static const Color red700  = Color(0xFFE03F3F);
  static const Color red800  = Color(0xFFC22F2F);
  static const Color red900  = Color(0xFFA02222);
  static const Color red1000 = Color(0xFF7A1717);
  static const Color red1100 = Color(0xFF550E0E);
  static const Color red1200 = Color(0xFF300707);

  // ── Green ────────────────────────────────────────────────────────────────────
  static const Color green100  = Color(0xFFF0FBF7);
  static const Color green200  = Color(0xFFD8F5EA);
  static const Color green300  = Color(0xFFBAEDDA);
  static const Color green400  = Color(0xFF96E3C8);
  static const Color green500  = Color(0xFF5ED4A9);
  static const Color green600  = Color(0xFF36C690);
  static const Color green700  = Color(0xFF1DB87E);
  static const Color green800  = Color(0xFF159A68);
  static const Color green900  = Color(0xFF0F7C52);
  static const Color green1000 = Color(0xFF0A5C3C);
  static const Color green1100 = Color(0xFF063D28);
  static const Color green1200 = Color(0xFF032215);

  // ── Blue ─────────────────────────────────────────────────────────────────────
  static const Color blue100  = Color(0xFFEFF4FE);
  static const Color blue200  = Color(0xFFDCE9FD);
  static const Color blue300  = Color(0xFFC5D9FB);
  static const Color blue400  = Color(0xFFA9C5F9);
  static const Color blue500  = Color(0xFF7BA8F4);
  static const Color blue600  = Color(0xFF5B90EE);
  static const Color blue700  = Color(0xFF3F7AE0);
  static const Color blue800  = Color(0xFF2E62C2);
  static const Color blue900  = Color(0xFF204CA0);
  static const Color blue1000 = Color(0xFF16387A);
  static const Color blue1100 = Color(0xFF0D2455);
  static const Color blue1200 = Color(0xFF071430);

  // ── Yellow ───────────────────────────────────────────────────────────────────
  static const Color yellow100 = Color(0xFFFFFBEB);
  static const Color yellow200 = Color(0xFFFFF4C2);
  static const Color yellow300 = Color(0xFFFEEC99);

  // ── Neutral (white → black) ───────────────────────────────────────────────
  static const Color neutral100  = Color(0xFFFFFFFF);
  static const Color neutral200  = Color(0xFFF5F5F5);
  static const Color neutral300  = Color(0xFFE6E6E6);
  static const Color neutral400  = Color(0xFFD9D9D9);
  static const Color neutral500  = Color(0xFFBFBFBF);
  static const Color neutral600  = Color(0xFF999999);
  static const Color neutral700  = Color(0xFF737373);
  static const Color neutral800  = Color(0xFF595959);
  static const Color neutral900  = Color(0xFF404040);
  static const Color neutral1000 = Color(0xFF262626);
  static const Color neutral1100 = Color(0xFF141414);
  static const Color neutral1200 = Color(0xFF000000);

  // ════════════════════════════════════════════════════════════════════════════
  // SEMANTIC TOKENS  (widgets always use these, never raw scales above)
  // ════════════════════════════════════════════════════════════════════════════

  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color primary      = purple900;   // #4C24A0
  static const Color primaryLight = purple700;   // #7A3FE0
  static const Color primaryDark  = purple1000;  // #381A7A

  // ── Background Gradient ──────────────────────────────────────────────────────
  static const Color appBgTop    = purple400;    // #CEBEFB — gradient top
  static const Color appBgMid    = purple300;    // #DDD0FC — 30% stop
  static const Color appBgBottom = grey100;      // #F8F7FA — gradient bottom

  /// Shared 3-stop gradient on all headers / auth screens / onboarding.
  static const LinearGradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [purple400, purple300, grey100],
    stops: [0.0, 0.30, 1.0],
  );

  // ── Splash ───────────────────────────────────────────────────────────────────
  static const Color splashGradientTop    = purple700;   // #7A3FE0
  static const Color splashGradientBottom = purple900;   // #4C24A0

  // ── Onboarding ───────────────────────────────────────────────────────────────
  static const Color onboardingBg                = appBgBottom;
  static const Color onboardingBgTop             = appBgTop;
  static const Color onboardingCircleBg          = purple400;   // #CEBEFB
  static const Color onboardingTitle             = grey1100;    // #1A1630
  static const Color onboardingSubtitle          = grey900;     // #443F63
  static const Color onboardingIndicatorActive   = purple900;   // #4C24A0
  static const Color onboardingIndicatorInactive = Color(0x554C24A0);

  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const Color authBgTop    = appBgTop;
  static const Color authBgBottom = appBgBottom;

  static const Color authTitle    = grey1100;   // #1A1630 — darkest heading
  static const Color authSubtitle = grey800;    // #5E5783 — medium body under title
  static const Color authLabel    = grey900;    // #443F63
  static const Color authHint     = grey500;    // #B8B2D1 — placeholder
  /// Register password hint pill — label + icon accent (Figma #0A5C3C).
  static const Color registerPasswordRequirementAccent = green900; // #0F7C52
  /// Register password hint pill background — Figma #F0FBF7.
  static const Color registerPasswordRequirementPillBg = Color(0xFFF0FBF7);

  static const Color authLink       = purple900;  // #4C24A0
  static const Color authForgotLink = purple900;
  /// Login / register footer line (“Don’t have an account? Sign up”) — Figma #443F63.
  static const Color authBottomText = grey900;
  static const Color authBottomLink = grey900;
  static const Color authOr         = grey600;    // #9990BB

  static const Color authPurple     = Color(0xE64C24A0); // purple900 with opacity
  static const Color authPurpleFade = Color(0x004C24A0);

  static const Color authInputBg = neutral100; // white

  /// Standard text field outline — Figma #DDD0FC.
  static const Color inputFieldBorder = purple300;
  /// Typed input text — Figma #141414.
  static const Color inputFieldText = neutral1100;
  /// Leading / trailing icons on standard text fields — Figma #4C24A0.
  static const Color inputFieldIcon = purple900;

  static const Color authInputBorder = inputFieldBorder;
  static const Color authButtonStart  = purple700;   // #7A3FE0
  static const Color authButtonEnd    = purple900;   // #4C24A0
  static const Color authSocialBorder = purple300;   // #DDD0FC — social outline
  static const Color authSocialText   = grey1100;    // #1A1630

  static const Color validSuccess = green700;   // #1DB87E

  // ── Semantic states ──────────────────────────────────────────────────────────
  static const Color error   = red700;      // #E03F3F
  static const Color success = green700;    // #1DB87E
  static const Color warning = yellow300;   // #FEEC99
  static const Color info    = blue600;     // #5B90EE

  static const Color secondary      = green700;
  static const Color secondaryLight = green500;
  static const Color secondaryDark  = green900;

  // ── Surfaces ─────────────────────────────────────────────────────────────────
  static const Color background = grey100;    // #F8F7FA
  static const Color surface    = neutral100; // white

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary   = grey900;  // #443F63
  static const Color textBody      = grey900;  // #443F63
  static const Color textSecondary = grey900;  // #443F63

  /// Project detail — chip labels, goal copy, body (#000000 Figma).
  static const Color projectDetailText = neutral1200;

  /// Home / Discover project card — fill (#F8F7FA).
  static const Color projectCardBg = grey100;
  /// Home / Discover project card — outer border (#BFBFBF, 1px).
  static const Color projectCardBorder = neutral500;
  /// Home / Discover project card — description dotted outline (#D9D9D9, 1px).
  static const Color projectCardDescriptionBorder = neutral400;

  /// Project funds history — summary metric values (#141414).
  static const Color projectFundsMetricValue = neutral1100;
  /// Ledger list row fill (#F8F7FA).
  static const Color projectFundsLedgerCardBg = grey100;
  /// Ledger row + icon tile outline (#BFBFBF).
  static const Color projectFundsLedgerBorder = neutral500;
  /// Icon tile fill behind the inner circle.
  static const Color projectFundsLedgerIconTileBg = surface;
  /// Contribution ledger glyph (#4C24A0).
  static const Color projectFundsLedgerContributionIcon = primary;
  /// Borrow ledger glyph (#A02222).
  static const Color projectFundsLedgerBorrowIcon = red900;
  /// Ledger date (#5E5783).
  static const Color projectFundsLedgerDate = grey800;
  /// Ledger + amount (#0F7C52).
  static const Color projectFundsLedgerAmountPositive = green900;
  /// Ledger − amount (#A02222).
  static const Color projectFundsLedgerAmountNegative = red900;
  static const Color textHint      = grey500;  // #B8B2D1

  // ── Borders & Dividers ────────────────────────────────────────────────────────
  static const Color border  = grey300;    // #E4E0EE
  static const Color divider = grey200;    // #EFECF5

  // ── Dashboard / Home / Discover ──────────────────────────────────────────────
  static const Color dashBg     = grey100;    // #F8F7FA
  static const Color cardBg     = neutral100; // white
  static const Color cardBorder = grey300;    // #E4E0EE

  // Status badges
  static const Color badgeOnGoingBg    = purple200;   // #EBE1FD
  static const Color badgeOnGoingText  = purple900;   // #4C24A0
  static const Color badgeCompletedBg  = green200;    // #D8F5EA
  static const Color badgeCompletedText = green900;   // #0F7C52
  /// My Borrow Request — pending banner (Figma).
  static const Color borrowPendingBannerBg = Color(0xFFFFF8E6);
  static const Color borrowPendingBannerText = Color(0xFFB8860B);
  /// Leader menu — “Stop the contribution” (Figma mustard).
  static const Color actionStopContributions = borrowPendingBannerText;
  /// Member vote summary — downvote tile.
  static const Color borrowVoteDownBg = Color(0xFFFCE8E8);

  // Progress bar
  static const Color progressBg   = grey300;    // #E4E0EE
  static const Color progressFill = green800;   // #1DB87E

  // Bottom navigation
  static const Color navActive   = purple900;   // #4C24A0
  static const Color navInactive = grey600;     // #9990BB
  static const Color navBg       = neutral100;  // white
  /// Inactive icon tondo only — pale lavender (Figma). Active state stays
  /// [navActive] + existing elevation/shadows.
  static const Color bottomNavIconCircle = purple100; // #F5F0FE

  // Filter chips
  static const Color chipActiveBg    = purple800;   // #6230C2
  static const Color chipActiveText  = neutral100;  // white
  static const Color chipInactiveBg  = neutral100;  // white
  static const Color chipInactiveText = grey900;    // #443F63
  static const Color chipBorder      = grey300;     // #E4E0EE

  // Search / input bg
  static const Color searchBarBg = grey100;    // #F8F7FA

  /// Project detail — member list row card + avatar (Figma).
  static const Color projectMemberCardBg = grey100;

  /// VFF profile — Contributions / Projects metric tiles (#F8F7FA).
  static const Color vffProfileMetricCardBg = grey100;

  /// VFF profile — joined project list row (#F8F7FA fill).
  static const Color vffJoinedProjectCardBg = grey100;
  static const Color vffJoinedProjectCardBorder = grey300;

  /// VFF profile — joined project row actions (Figma).
  static const Color vffJoinedProjectJoinBg = purple400;
  static const Color vffJoinedProjectRequestBg = grey100;
  static const Color vffJoinedProjectRequestBorder = purple300;

  /// Request Sent chip / disabled CTA (#F5F0FE).
  static const Color vffRequestSentChipBg = purple100;
  static const Color projectMemberAvatarBg = purple300;
  static const Color projectMemberAvatarInitials = neutral1200;

  /// Add Friend on project member row (Figma border #DDD0FC).
  static const Color projectMemberAddFriendBorder = purple300;

  /// VFF badge — Action/Primary/Pressed (Figma).
  static const Color actionPrimaryPressed = purple800; // #6230C2

  /// Make Co-Leader confirmation dialog primary CTA (Figma #6230C2).
  static const Color makeCoLeaderDialogButton = purple800;
  static const Color actionPrimaryBorderLight = grey100; // #F8F7FA
  static const Color actionPrimaryBorderDark = purple600; // #9268EC
  static const Color actionPrimaryInnerShadow = Color(0xFFCABEE5);

  /// Leader badge — Action/Information (Figma).
  static const Color actionInformationPressed = blue800; // #2E62C2
  static const Color actionInformationBorderLight = Color(0xFFF4F5F7);
  static const Color actionInformationBorderDark = blue900; // #204CA0
  static const Color actionInformationInnerShadow = Color(0xFFC3CEE2);

  /// Co-leader badge — Action/Success/Pressed (Figma).
  static const Color actionSuccessPressed = green800; // #159A68
  static const Color actionSuccessBorderLight = green100; // #F0FBF7
  static const Color actionSuccessBorderDark = green900; // #0F7C52
  static const Color actionSuccessInnerShadow = Color(0xFF58D4A4);

  // Dark pill action button (inside cards)
  static const Color cardActionBtn = grey1100; // #1A1630

  /// Full-width “Back to Home” outline (Figma #7B73A3).
  static const Color backToHomeButtonBorder = grey700;

  // ── Profile / Payment ────────────────────────────────────────────────────────
  static const Color logoutBtn      = red700;     // #E03F3F
  /// Profile settings menu card fill (Figma — white).
  static const Color settingsCardBg = neutral100;

  // Payment card gradient — vivid purple (legacy list tiles)
  static const Color payCardGradientStart = purple700;  // #7A3FE0
  static const Color payCardGradientEnd   = purple500;  // #B098F5
  /// Card detail sheet — white surface + monotone noise (Figma).
  static const Color payCardSurfaceBg  = neutral100;    // #FFFFFF
  static const Color payCardNoise      = Color(0xFFDFD9ED);
  static const Color payCardPrimaryBadge = purple600;   // #9268EC

  /// Instant withdraw method card — drop shadow (Figma #A498C0 @ 20%).
  static const Color withdrawInstantCardShadow = Color(0xFFA498C0);

  /// Vestie User Guidelines — section title (Figma #140930).
  static const Color guidelineTitle = Color(0xFF140930);

  // ── Transactions ─────────────────────────────────────────────────────────────
  static const Color txPositive = green700;    // #1DB87E
  static const Color txNegative = red700;      // #E03F3F

  static const Color txDepositBg   = green100;   // #F0FBF7
  static const Color txDepositIcon = green700;   // #1DB87E
  static const Color txContribBg   = red100;     // #FEF2F2
  static const Color txContribIcon = red700;     // #E03F3F
  static const Color txBorrowBg    = purple200;  // #EBE1FD
  static const Color txBorrowIcon  = purple900;  // #4C24A0

  /// Dim layer behind modal bottom sheets (Figma).
  static Color get modalBarrier => grey1100.withValues(alpha: 0.45);
}
