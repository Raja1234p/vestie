import 'dart:async' show Completer, unawaited;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/router/route_args/project_detail_flow_args.dart';
import '../../../app/router/route_args/user_vff_flow_args.dart';
import '../../../features/dashboard/presentation/models/dashboard_shell_args.dart';
import '../../../features/project_detail/domain/entities/project_detail_entity.dart';
import '../../../features/project_detail/presentation/navigation/open_project_from_card.dart';
import '../../../user/features/home/domain/entities/project_category_extensions.dart';
import '../../auth/app_auth_session.dart';
import '../../di/service_locator.dart';
import 'push_notification_payload.dart';

/// Bottom-nav tab indices — match `DashboardScreen`'s tab order.
const _homeTabIndex = 0;
const _walletTabIndex = 3;

/// Routes a tapped push notification to its matching screen.
///
/// [FcmPushService] has no [BuildContext] — it runs during bootstrap (cold
/// start `getInitialMessage`) and from FCM's own listeners — so navigation
/// goes through the app's [GoRouter] instance directly, the same pattern
/// used by `ProjectInviteDeepLinkService`. A tap that arrives before the
/// router is attached (cold start, pre-`runApp`) is queued and replayed
/// once [attach] runs from `MainApp`'s first frame.
///
/// Cold start also waits until splash / login / agreement have finished.
/// Splash always `go`s to Home after ~3s; pushing VFF (or join-requests)
/// during splash used to open the right screen then get replaced by Home.
class PushNotificationRouter {
  PushNotificationRouter._();

  static GoRouter? _router;
  static PushNotificationPayload? _pendingTap;
  static bool _listening = false;
  static bool _flushing = false;

  /// Call once the router/navigator exists (`MainApp` first frame) — mirrors
  /// `ProjectInviteDeepLinkService.start`.
  static void attach(GoRouter router) {
    if (_listening && _router != null) {
      _router!.routerDelegate.removeListener(_onRouterChanged);
      _listening = false;
    }
    _router = router;
    router.routerDelegate.addListener(_onRouterChanged);
    _listening = true;
    unawaited(_flushIfReady());
  }

  /// Called from [FcmPushService] on every notification tap (background tap,
  /// terminated-launch `getInitialMessage`, or local-notification tap).
  static void handleTap(PushNotificationPayload payload) {
    _pendingTap = payload;
    unawaited(_flushIfReady());
  }

  static void _onRouterChanged() => unawaited(_flushIfReady());

  /// Splash / auth gates that must finish before a push `push`es a screen.
  /// Otherwise splash `go(/dashboard)` replaces the notification route.
  static bool isLaunchRouteBlocking(String location) {
    if (location.isEmpty || location == AppRoutes.splash) return true;
    return location == AppRoutes.onboarding ||
        location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.verify ||
        location == AppRoutes.forgotPassword ||
        location == AppRoutes.resetPassword ||
        location == AppRoutes.passwordUpdatedSuccess ||
        location == AppRoutes.agreement;
  }

  static String get _currentLocation {
    final router = _router;
    if (router == null) return AppRoutes.splash;
    try {
      return router.state.matchedLocation;
    } catch (_) {
      return AppRoutes.splash;
    }
  }

  static Future<void> _flushIfReady() async {
    if (_flushing) return;
    final pending = _pendingTap;
    if (pending == null || _router == null) return;
    if (!AppAuthSession.instance.isAuthenticated) return;
    if (isLaunchRouteBlocking(_currentLocation)) return;

    _flushing = true;
    _pendingTap = null;
    try {
      await _waitForNextFrame();
      if (isLaunchRouteBlocking(_currentLocation)) {
        _pendingTap ??= pending;
        return;
      }
      await _route(pending);
    } finally {
      _flushing = false;
      if (_pendingTap != null) unawaited(_flushIfReady());
    }
  }

  static Future<void> _waitForNextFrame() async {
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.idle) {
      await Future<void>.delayed(Duration.zero);
    }
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  static Future<void> _route(PushNotificationPayload payload) async {
    switch (payload.tapTarget) {
      case PushNotificationTapTarget.projectDetail:
        await _openProject(payload.projectId);
      case PushNotificationTapTarget.walletTab:
        _openDashboardTab(_walletTabIndex, reloadWallet: true);
      case PushNotificationTapTarget.vffHubRequests:
        _openVffRequests();
      case PushNotificationTapTarget.joinRequests:
        await _openJoinRequests(payload.projectId);
      case PushNotificationTapTarget.homeTab:
        _openDashboardTab(_homeTabIndex);
    }
  }

  static void _openDashboardTab(
    int tabIndex, {
    bool reloadWallet = false,
  }) {
    if (!AppAuthSession.instance.isAuthenticated) return;
    final router = _router;
    if (router == null) return;

    router.go(
      AppRoutes.dashboard,
      extra: DashboardShellArgs(
        initialTabIndex: tabIndex,
        reloadWallet: reloadWallet,
        navigationMark: DateTime.now().microsecondsSinceEpoch,
      ),
    );
  }

  static void _openVffRequests() {
    if (!AppAuthSession.instance.isAuthenticated) return;
    final router = _router;
    if (router == null) return;

    router.push(
      AppRoutes.userVffMain,
      extra: UserVffHubRouteArgs.requestsTab(),
    );
  }

  /// Join-requests screen is the same for vacation, emergency, and investment.
  /// [GET /projects/{id}] confirms the project still exists and the viewer
  /// is a leader/co-leader before pushing.
  static Future<void> _openJoinRequests(String? projectId) async {
    if (projectId == null || projectId.isEmpty) return;
    if (!AppAuthSession.instance.isAuthenticated) return;

    final router = _router;
    if (router == null) return;

    final detail = await _loadProjectDetail(projectId);
    if (detail == null) return;
    if (!detail.isModeratorView) {
      await _openProject(projectId);
      return;
    }

    router.push(
      AppRoutes.joinRequests,
      extra: JoinRequestsRouteArgs(projectId: detail.id),
    );
  }

  /// Resolves [projectId] via `GET /projects/{id}` first because the notify
  /// payload does not include the project category, and category decides
  /// which detail route (`/project/detail` vs `/project/investment-detail`)
  /// to push — see [openProjectDetailById].
  static Future<void> _openProject(String? projectId) async {
    if (projectId == null || projectId.isEmpty) return;
    if (!AppAuthSession.instance.isAuthenticated) return;

    final router = _router;
    if (router == null) return;

    final detail = await _loadProjectDetail(projectId);
    if (detail == null) return;

    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    openProjectDetailById(
      context,
      projectId: detail.id,
      isInvestment: detail.category.isInvestment,
      initialProjectName: detail.name,
    );
  }

  static Future<ProjectDetailEntity?> _loadProjectDetail(String projectId) async {
    final result = await ServiceLocator.instance.projectDetailRepository
        .getProjectDetail(projectId: projectId);
    return result.fold((_) => null, (value) => value);
  }
}
