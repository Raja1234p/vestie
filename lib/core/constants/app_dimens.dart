import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centralized dimensions ensuring zero hardcoded numbers in widgets.
class AppDimens {
  AppDimens._();

  // Padding & Margins
  static double get p4 => 4.0.w;
  static double get p8 => 8.0.w;
  static double get p12 => 12.0.w;
  static double get p14 => 14.0.w;
  static double get p16 => 16.0.w; // Standard screen padding
  static double get p20 => 20.0.w;
  static double get p24 => 24.0.w;
  static double get p32 => 32.0.w;
  static double get p40 => 40.0.w;
  static double get p48 => 48.0.w;
  static double get p64 => 64.0.w;

  /// Create project amount sheet — vertical gap between close icon and title (Figma 70).
  static double get createProjectAmountSheetIconTitleVerticalGap => 70.0.h;

  /// Create project amount sheet — gap between question and amount (Figma 14).
  static double get createProjectAmountSheetTitleValueGap => 14.0.h;

  /// Horizontal gutters used on some auth / VFF sheets (between p16–p24).
  static double get p18 => 18.0.w;
  static double get p22 => 22.0.w;

  /// Vertical rhythm (ScreenUtil heights).
  static double get v4 => 4.0.h;
  static double get v6 => 6.0.h;
  static double get v8 => 8.0.h;
  static double get v10 => 10.0.h;
  static double get v12 => 12.0.h;
  static double get v14 => 14.0.h;
  static double get v15 => 15.0.h;
  static double get v16 => 16.0.h;
  static double get v18 => 18.0.h;
  static double get v20 => 20.0.h;
  static double get v22 => 22.0.h;
  static double get v24 => 24.0.h;
  static double get v28 => 28.0.h;
  static double get v32 => 32.0.h;
  static double get v34 => 34.0.h;

  /// Bottom gap for project detail scroll bodies (above system nav / home indicator).
  static double get projectDetailScrollBottomGap => v4;
  static double get v48 => 48.0.h;

  /// Shared [DottedBorder] dash lengths (project card description, agreement, etc.).
  static const List<double> dottedBorderDashPattern = [10, 6];

  /// Invite members sheet — gap above/below dashed dividers; hint-to-first-divider.
  static double get inviteMembersDividerGutter => v24;
  static double get inviteMembersHintToDivider => v34;

  /// Space below “Share outside Vestie” inside the sheet card (Figma 34).
  static double get inviteMembersSheetBottom => v34;

  /// Room for stacked primary footer on dense profile layouts.
  static double get v92 => 92.0.h;

  /// Home + Discover tab gradient header band.
  static double get homeHeaderHeight => 140.0.h;

  /// Standard post-auth header band (all screens except Home / Discover).
  static double get postAuthHeaderHeight => 130.0.h;

  /// Gap below gradient header band before body (Home tab only).
  static const double homeContentTopGap = 4;

  /// Gap below gradient header band before body (all tabs/screens except Home).
  static const double postAuthContentTopGap = 10;

  /// Scroll body below [PostAuthFlowSubHeader] — matches Edit Profile (`20.w` / `16.h`).
  static EdgeInsets get postAuthFlowScrollPadding =>
      EdgeInsets.fromLTRB(p20, 0, p20, v16);

  /// Same as [postAuthFlowScrollPadding] plus keyboard inset for form flows.
  static EdgeInsets postAuthFlowScrollPaddingWithKeyboard(BuildContext context) {
    return EdgeInsets.fromLTRB(
      p20,
      0,
      p20,
      v16 + MediaQuery.viewInsetsOf(context).bottom,
    );
  }

  /// VFF rounded white sheet padding presets.
  static EdgeInsets get sheetInsetComfort =>
      EdgeInsets.fromLTRB(p18, v20, p18, v4);

  static EdgeInsets get sheetInsetList =>
      EdgeInsets.fromLTRB(p18, v20, p18, v8);

  /// VFF full-list screens (VFF Requests, Project Invitations).
  static EdgeInsets get vffInboxFullListSheetInset =>
      EdgeInsets.fromLTRB(p18, v6, p18, v8);

  /// VFF full-list empty state — horizontal inset only so content stays centered.
  static EdgeInsets get vffInboxFullListEmptyInset =>
      EdgeInsets.symmetric(horizontal: p18);

  static EdgeInsets get sheetInsetProfile =>
      EdgeInsets.fromLTRB(p18, v16, p18, v16);

  static EdgeInsets get screenHorizontalComfort =>
      EdgeInsets.symmetric(horizontal: p22);

  /// Hero illustration square (VFF success / mocks).
  static double get illustrationLg => 200.0.w;

  /// VFF hub / list empty state hero (`project_invitation_hero.png`).
  static double get vffEmptyStateIllustration => 150.0.w;

  static EdgeInsets get removeDialogOuterInsets =>
      EdgeInsets.symmetric(horizontal: p22);

  static EdgeInsets get removeDialogInnerInsets =>
      EdgeInsets.fromLTRB(p20, v22, p20, v18);

  // Icon Sizes
  static double get iconSmall => 16.0.w;
  static double get iconMedium => 24.0.w;
  static double get iconLarge => 32.0.w;

  /// Bold dialog glyphs (e.g. destructive “X”).
  static double get iconGlyphLg => 40.0.r;

  /// App bar / header back chevron (keep in sync with [AppBackButton]).
  static double get backIconSize => iconMedium;

  // Button Heights
  static double get buttonHeightSm => 40.0.h;
  static double get buttonHeightMd => 48.0.h;

  /// VFF dialogs / stacked rows (matches Figma 50px rails).
  static double get buttonHeightDialogCompact => 50.0.h;
  static double get buttonHeightLg => 56.0.h;

  /// Error icon medallion diameter in dialogs.
  static double get dialogErrorIconDiameter => 72.0.r;

  /// Dialog hero illustrations (success + failure) — Figma 132×145.
  static double get dialogHeroIconWidth => 132.0.w;
  static double get dialogHeroIconHeight => 145.0.h;

  /// [AppAssets.statusFailure] — screens + dialogs.
  static double get failureIconWidth => dialogHeroIconWidth;
  static double get failureIconHeight => dialogHeroIconHeight;

  /// [AppAssets.successProjectCreated] — success dialogs.
  static double get successDialogIconWidth => dialogHeroIconWidth;
  static double get successDialogIconHeight => dialogHeroIconHeight;

  /// Below the bottom action in [AppActionDialog] / [AppActionBottomSheet] (Figma 24).
  static double get dialogActionBottomInset => v24;

  /// Project detail member row — avatar circle (equal width & height).
  static double get projectMemberAvatarSize => 48.0.r;

  /// Gap between avatar and member name in member row (Figma 14).
  static double get projectMemberAvatarNameGap => 14.0.w;

  /// Gap between member name and Leader / VFF badges (Figma 8).
  static double get projectMemberNameBadgeGap => 8.0.h;

  static EdgeInsets get projectMemberCardPadding =>
      EdgeInsets.symmetric(horizontal: p14, vertical: p14);

  /// Vacation / Emergency detail — Borrow requests | Manage members toggle (Figma).
  static double get projectDetailToggleBarOuterHeight => 49.0.h;
  static double get projectDetailToggleTabInnerHeight => 33.0.h;
  static double get projectDetailToggleBarOuterRadius => 16.0.r;
  static double get projectDetailToggleTabInnerRadius => 12.0.r;
  static double get projectDetailToggleLabelFontSize => 14.0.sp;

  /// Wallet tab — deposit/withdraw CTAs (Figma pill).
  static double get walletActionButtonHeight => 48.0.h;
  static double get walletActionButtonRadius => 999.0.r;

  /// Payment method picker row (Visa / Master / Wallet).
  static double get paymentMethodRowHeight => 72.0.h;

  /// Gap between payment method rows in a list.
  static double get paymentMethodRowGap => v8;

  /// Wallet recent-activity transaction cards.
  static double get walletTransactionRowGap => v12;
}

class AppRadius {
  AppRadius._();

  static double get r4 => 4.0.r;
  static double get r8 => 8.0.r;

  /// VFF hub Accept / Decline / Request Sent action corners.
  static double get vffHubRequestActionButton => 10.0.r;

  /// [AppActionDialog] primary/secondary action corners (Figma: 24).
  static double get dialogActionButton => r24;
  static double get r12 => 12.0.r;
  static double get r14 => 14.0.r;
  static double get r16 => 16.0.r;
  static double get r22 => 22.0.r;
  static double get r24 => 24.0.r;
  static double get r32 => 32.0.r;

  static double get button => 12.0.r; // Standard button radius
  static double get card => 16.0.r; // Standard card radius
}
