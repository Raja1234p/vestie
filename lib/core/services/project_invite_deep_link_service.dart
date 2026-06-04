import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../core/auth/app_auth_session.dart';
import 'package:vestie/features/invites/presentation/constants/invite_flow_constants.dart';

import 'project_invite_link_parser.dart';
import '../storage/pending_project_invite_store.dart';

/// Listens for HTTPS `/join/{code}` and `vestie://join/{code}`.
/// Invitation UI requires a logged-in session; signed-out users are sent to login.
final class ProjectInviteDeepLinkService {
  ProjectInviteDeepLinkService._();

  static final ProjectInviteDeepLinkService instance =
      ProjectInviteDeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  GoRouter? _router;
  bool _didCaptureInitialLink = false;

  /// Call from [main] before [runApp] so splash sees a pending code immediately.
  Future<void> captureInitialInviteIfAny() async {
    if (_didCaptureInitialLink) return;
    _didCaptureInitialLink = true;
    await _persistInviteFromUri(await _appLinks.getInitialLink());
  }

  /// Warm-start links only; cold start is handled via [captureInitialInviteIfAny] + splash.
  Future<void> start(GoRouter router) async {
    _router = router;
    _subscription ??=
        _appLinks.uriLinkStream.listen((uri) => _handleUri(uri, navigate: true));
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _router = null;
  }

  Future<void> _persistInviteFromUri(Uri? uri) async {
    if (uri == null || !InviteFlowConstants.isInviteDeepLink(uri)) return;
    final code = parseProjectInviteCode(uri);
    if (code == null || code.isEmpty) return;
    await PendingProjectInviteStore.save(code);
  }

  Future<void> _handleUri(Uri uri, {required bool navigate}) async {
    await _persistInviteFromUri(uri);
    if (!navigate) return;

    final router = _router;
    if (router == null) return;

    final code = parseProjectInviteCode(uri);
    if (code == null || code.isEmpty) return;

    await AppAuthSession.instance.refresh();
    if (!AppAuthSession.instance.isAuthenticated) {
      router.go(AppRoutes.login);
      return;
    }

    router.go(AppRoutes.projectInvitation(code));
  }
}
