import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/app_strings.dart';
import '../storage/showcase_prefs.dart';
import '../theme/app_colors.dart';

/// GlobalKeys used as ShowcaseView registry ids (v5 does not attach them to elements).
abstract final class AppShowcaseKeys {
  static final navHome = GlobalKey();
  static final navDiscover = GlobalKey();
  static final navCreate = GlobalKey();
  static final navWallet = GlobalKey();
  static final navProfile = GlobalKey();
  static final headerVff = GlobalKey();
  static final leaderJoinRequests = GlobalKey();
  static final leaderContribute = GlobalKey();
  static final leaderMenu = GlobalKey();
  static final vffHubTabs = GlobalKey();

  static List<GlobalKey> get dashboardTour => [
        navHome,
        navDiscover,
        navCreate,
        navWallet,
        navProfile,
        headerVff,
      ];

  static List<GlobalKey> get leaderDetailTour => [
        leaderJoinRequests,
        leaderContribute,
        leaderMenu,
      ];

  static List<GlobalKey> get vffHubTour => [vffHubTabs];
}

/// Registers ShowcaseView once and starts tours when targets exist.
abstract final class AppShowcase {
  static AppShowcaseTour? _active;
  static bool _registered = false;
  static bool _starting = false;

  /// Returning users already have groups — never block them with a first-run overlay.
  static bool shouldSuppressForReturningUser({
    required bool hasProjects,
    required bool dashboardTourAlreadyDone,
  }) =>
      hasProjects && !dashboardTourAlreadyDone;

  /// Leader / VFF tours only after the dashboard tour was finished or skipped.
  static bool canStartFollowUpTour({required bool dashboardTourAlreadyDone}) =>
      dashboardTourAlreadyDone;

  static void register() {
    if (_registered) {
      try {
        ShowcaseView.get().unregister();
      } catch (_) {}
      _registered = false;
    }
    ShowcaseView.register(
      skipIfTargetNotPresent: true,
      disableBarrierInteraction: true,
      enableAutoScroll: true,
      overlayColor: AppColors.grey1200,
      overlayOpacity: 0.62,
      onFinish: () => unawaited(_completeActiveTour()),
      onDismiss: (_) => unawaited(_completeActiveTour()),
      globalTooltipActionConfig: const TooltipActionConfig(
        alignment: MainAxisAlignment.spaceBetween,
        position: TooltipActionPosition.inside,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: AppStrings.btnSkip,
          backgroundColor: AppColors.grey200,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            color: AppColors.grey1100,
          ),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: AppStrings.btnNext,
          backgroundColor: AppColors.purple800,
          textStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            color: AppColors.surface,
          ),
        ),
      ],
    );
    _registered = true;
  }

  static void unregister() {
    if (!_registered) return;
    try {
      ShowcaseView.get().unregister();
    } catch (_) {}
    _registered = false;
    _active = null;
    _starting = false;
  }

  /// Overlay highlight. Child taps stay unchanged after the tour (and during it).
  static Widget highlight({
    required GlobalKey key,
    required String title,
    required String description,
    required Widget child,
    TooltipPosition? tooltipPosition,
  }) {
    return Showcase(
      key: key,
      title: title,
      description: description,
      tooltipPosition: tooltipPosition,
      disableDefaultTargetGestures: true,
      disableBarrierInteraction: true,
      overlayColor: AppColors.grey1200,
      overlayOpacity: 0.62,
      tooltipBackgroundColor: AppColors.surface,
      textColor: AppColors.grey1100,
      titleTextStyle: GoogleFonts.lato(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.grey1100,
      ),
      descTextStyle: GoogleFonts.lato(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.grey800,
      ),
      tooltipPadding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
      targetBorderRadius: BorderRadius.circular(12.r),
      targetPadding: EdgeInsets.zero,
      child: child,
    );
  }

  /// Same as [highlight] when [enabled], otherwise the original [child].
  static Widget wrapIf({
    required bool enabled,
    required GlobalKey key,
    required String title,
    required String description,
    required Widget child,
    TooltipPosition? tooltipPosition,
  }) {
    if (!enabled) return child;
    return highlight(
      key: key,
      title: title,
      description: description,
      tooltipPosition: tooltipPosition,
      child: child,
    );
  }

  static void maybeStartDashboard() =>
      unawaited(_maybeStart(AppShowcaseTour.dashboard, AppShowcaseKeys.dashboardTour));

  /// Existing accounts that already have groups skip every tour.
  static void suppressIfReturningUser({required bool hasProjects}) =>
      unawaited(_suppressIfReturningUser(hasProjects: hasProjects));

  static Future<void> _suppressIfReturningUser({required bool hasProjects}) async {
    final dashboardDone =
        await ShowcasePrefs.hasCompleted(AppShowcaseTour.dashboard);
    if (!shouldSuppressForReturningUser(
      hasProjects: hasProjects,
      dashboardTourAlreadyDone: dashboardDone,
    )) {
      return;
    }
    await ShowcasePrefs.markCompleted(AppShowcaseTour.dashboard);
    await ShowcasePrefs.markCompleted(AppShowcaseTour.leaderDetail);
    await ShowcasePrefs.markCompleted(AppShowcaseTour.vffHub);
  }

  static void maybeStartLeaderDetail({
    required bool isModerator,
    required bool completedProfileDetail,
  }) {
    if (!isModerator || completedProfileDetail) return;
    unawaited(
      _maybeStart(AppShowcaseTour.leaderDetail, AppShowcaseKeys.leaderDetailTour),
    );
  }

  static void maybeStartVffHub() =>
      unawaited(_maybeStart(AppShowcaseTour.vffHub, AppShowcaseKeys.vffHubTour));

  static Future<void> _maybeStart(
    AppShowcaseTour tour,
    List<GlobalKey> keys,
  ) async {
    if (!_registered || _active != null || _starting) return;
    if (await ShowcasePrefs.hasCompleted(tour)) return;
    if (tour != AppShowcaseTour.dashboard &&
        !canStartFollowUpTour(
          dashboardTourAlreadyDone:
              await ShowcasePrefs.hasCompleted(AppShowcaseTour.dashboard),
        )) {
      return;
    }
    ShowcaseView view;
    try {
      view = ShowcaseView.get();
    } catch (_) {
      return;
    }
    if (view.isShowcaseRunning) return;
    _starting = true;
    _active = tour;
    try {
      view.startShowCase(
        keys,
        delay: const Duration(milliseconds: 450),
      );
    } catch (_) {
      _active = null;
    } finally {
      _starting = false;
    }
  }

  static Future<void> _completeActiveTour() async {
    final tour = _active;
    _active = null;
    if (tour == null) return;
    await ShowcasePrefs.markCompleted(tour);
  }
}
