import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/app_auth_session.dart';
import '../../core/storage/pending_project_invite_store.dart';
import 'app_routes.dart';

/// Invite-link routing only — does not affect Discover/Home join flows.
final class ProjectInviteNavigation {
  ProjectInviteNavigation._();

  static Future<void> goAfterAuth(
    BuildContext context, {
    required bool disclaimerAccepted,
  }) async {
    await AppAuthSession.instance.refresh();
    if (!context.mounted) return;

    if (!AppAuthSession.instance.isAuthenticated) {
      context.go(AppRoutes.login);
      return;
    }

    final pending = await PendingProjectInviteStore.consume();
    if (!context.mounted) return;

    if (pending != null && pending.isNotEmpty) {
      context.go(AppRoutes.projectInvitation(pending));
      return;
    }

    if (disclaimerAccepted) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.agreement);
    }
  }

  static Future<void> goMaybeLater(BuildContext context) async {
    await AppAuthSession.instance.refresh();
    if (!context.mounted) return;
    if (AppAuthSession.instance.isAuthenticated) {
      await PendingProjectInviteStore.clear();
      if (!context.mounted) return;
      context.go(AppRoutes.dashboard);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }
}
