import 'dart:async';

import 'package:go_router/go_router.dart';

import '../../core/auth/app_auth_session.dart';
import '../../core/services/project_invite_link_parser.dart';
import '../../core/storage/pending_project_invite_store.dart';
import 'app_routes.dart';

/// Normalizes invite deep links and blocks `/join/:code` for signed-out users.
final class ProjectInviteRouteGuard {
  ProjectInviteRouteGuard._();

  static String? redirect(GoRouterState state) {
    return redirectForInvite(
      uri: state.uri,
      pathParameters: state.pathParameters,
      isAuthenticated: AppAuthSession.instance.isAuthenticated,
    );
  }

  /// Testable invite redirect without a live [GoRouterState].
  static String? redirectForInvite({
    required Uri uri,
    required Map<String, String> pathParameters,
    required bool isAuthenticated,
  }) {
    final normalizedInvite = _normalizeInviteLocation(uri);
    if (normalizedInvite != null) return normalizedInvite;

    final inviteCode = _inviteCode(uri: uri, pathParameters: pathParameters);
    if (inviteCode == null) return null;

    if (isAuthenticated) return null;

    PendingProjectInviteStore.stage(inviteCode);
    unawaited(PendingProjectInviteStore.save(inviteCode));
    return AppRoutes.login;
  }

  static String? _normalizeInviteLocation(Uri uri) {
    final code = parseProjectInviteCode(uri);
    if (code == null || code.isEmpty) return null;
    final target = AppRoutes.projectInvitation(code);
    if (uri.path == Uri.parse(target).path) return null;
    return target;
  }

  static String? _inviteCode({
    required Uri uri,
    required Map<String, String> pathParameters,
  }) {
    final fromParam = pathParameters['inviteCode']?.trim();
    if (fromParam != null && fromParam.isNotEmpty) return fromParam;
    return parseProjectInviteCode(uri);
  }
}
