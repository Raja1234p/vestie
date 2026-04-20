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
  static const Color authSubtitle = grey900;    // #443F63
  static const Color authLabel    = grey900;    // #443F63
  static const Color authHint     = grey500;    // #B8B2D1 — placeholder

  static const Color authLink       = purple900;  // #4C24A0
  static const Color authForgotLink = purple900;
  static const Color authBottomText = grey700;    // #7B73A3
  static const Color authBottomLink = purple900;
  static const Color authOr         = grey600;    // #9990BB

  static const Color authPurple     = Color(0xE64C24A0); // purple900 with opacity
  static const Color authPurpleFade = Color(0x004C24A0);

  static const Color authInputBg      = neutral100;  // white
  static const Color authInputBorder  = grey300;     // #E4E0EE
  static const Color authButtonStart  = purple700;   // #7A3FE0
  static const Color authButtonEnd    = purple900;   // #4C24A0
  static const Color authSocialBorder = grey300;     // #E4E0EE
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

  // Progress bar
  static const Color progressBg   = grey300;    // #E4E0EE
  static const Color progressFill = green800;   // #1DB87E

  // Bottom navigation
  static const Color navActive   = purple900;   // #4C24A0
  static const Color navInactive = grey600;     // #9990BB
  static const Color navBg       = neutral100;  // white

  // Filter chips
  static const Color chipActiveBg    = purple800;   // #4C24A0
  static const Color chipActiveText  = neutral100;  // white
  static const Color chipInactiveBg  = neutral100;  // white
  static const Color chipInactiveText = grey900;    // #443F63
  static const Color chipBorder      = grey300;     // #E4E0EE

  // Search / input bg
  static const Color searchBarBg = grey100;    // #F8F7FA

  // Dark pill action button (inside cards)
  static const Color cardActionBtn = grey1100; // #1A1630

  // ── Profile / Payment ────────────────────────────────────────────────────────
  static const Color logoutBtn      = red700;     // #E03F3F
  static const Color settingsCardBg = grey100;    // #F8F7FA

  // Payment card gradient — vivid purple
  static const Color payCardGradientStart = purple700;  // #7A3FE0
  static const Color payCardGradientEnd   = purple500;  // #B098F5

  // ── Transactions ─────────────────────────────────────────────────────────────
  static const Color txPositive = green700;    // #1DB87E
  static const Color txNegative = red700;      // #E03F3F

  static const Color txDepositBg   = green100;   // #F0FBF7
  static const Color txDepositIcon = green700;   // #1DB87E
  static const Color txContribBg   = red100;     // #FEF2F2
  static const Color txContribIcon = red700;     // #E03F3F
  static const Color txBorrowBg    = purple200;  // #EBE1FD
  static const Color txBorrowIcon  = purple900;  // #4C24A0
}
