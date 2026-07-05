import 'dart:async' show unawaited;

import 'package:go_router/go_router.dart';

import '../../auth/app_auth_session.dart';
import '../../di/service_locator.dart';
import '../../../features/project_detail/domain/entities/project_detail_entity.dart';
import '../../../features/project_detail/presentation/navigation/open_project_from_card.dart';
import '../../../user/features/home/domain/entities/project_category_extensions.dart';
import 'push_notification_payload.dart';

/// Routes a tapped push notification to its matching screen.
///
/// [FcmPushService] has no [BuildContext] — it runs during bootstrap (cold
/// start `getInitialMessage`) and from FCM's own listeners — so navigation
/// goes through the app's [GoRouter] instance directly, the same pattern
/// used by `ProjectInviteDeepLinkService`. A tap that arrives before the
/// router is attached (cold start, pre-`runApp`) is queued and replayed
/// once [attach] runs from `MainApp`'s first frame.
class PushNotificationRouter {
  PushNotificationRouter._();

  static GoRouter? _router;
  static PushNotificationPayload? _pendingTap;

  /// Call once the router/navigator exists (`MainApp` first frame) — mirrors
  /// `ProjectInviteDeepLinkService.start`.
  static void attach(GoRouter router) {
    _router = router;
    final pending = _pendingTap;
    _pendingTap = null;
    if (pending != null) unawaited(_route(pending));
  }

  /// Called from [FcmPushService] on every notification tap (background tap
  /// or terminated-launch `getInitialMessage`).
  static void handleTap(PushNotificationPayload payload) {
    if (_router == null) {
      _pendingTap = payload;
      return;
    }
    unawaited(_route(payload));
  }

  static Future<void> _route(PushNotificationPayload payload) async {
    switch (payload.type) {
      case PushNotificationType.projectCreated:
        await _openProject(payload.projectId);
      case PushNotificationType.unknown:
        break;
    }
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

    final result = await ServiceLocator.instance.projectDetailRepository
        .getProjectDetail(projectId: projectId);
    final ProjectDetailEntity? detail = result.fold(
      (_) => null,
      (value) => value,
    );
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
}
