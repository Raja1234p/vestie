import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/app_auth_session.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/di/service_locator.dart';
import '../../core/storage/pending_project_invite_store.dart';
import '../../features/dashboard/domain/dashboard_prefetch.dart';
import 'app_routes.dart';

/// Invite-link routing only — does not affect Discover/Home join flows.
final class ProjectInviteNavigation {
  ProjectInviteNavigation._();

  /// Whether the user has accepted the risk disclaimer (prefs cache, then API).
  static Future<bool> isRiskDisclaimerAccepted() async {
    if (DashboardPrefetch.riskDisclaimerAccepted) return true;

    final cached = await ServiceLocator.instance.sharedPrefs
        .getBool(StorageKeys.disclaimerAccepted);
    if (cached == true) {
      DashboardPrefetch.markRiskDisclaimerAccepted();
      return true;
    }

    final result = await ServiceLocator.instance.getRiskDisclaimerUseCase();
    return result.fold(
      (_) => false,
      (disclaimer) {
        if (disclaimer.accepted) {
          DashboardPrefetch.markRiskDisclaimerAccepted();
        }
        return disclaimer.accepted;
      },
    );
  }

  /// Post-login/register: agreement before invite; [consume] invite only after disclaimer.
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

    final accepted =
        disclaimerAccepted || await isRiskDisclaimerAccepted();
    if (!context.mounted) return;

    if (!accepted) {
      context.go(AppRoutes.agreement);
      return;
    }

    final pending = await PendingProjectInviteStore.consume();
    if (!context.mounted) return;

    if (pending != null && pending.isNotEmpty) {
      context.go(AppRoutes.projectInvitation(pending));
      return;
    }

    context.go(AppRoutes.dashboard);
  }

  /// Warm deep link / direct navigation when already signed in.
  static Future<void> goToInviteOrAgreement(
    BuildContext context, {
    required String inviteCode,
  }) async {
    final code = inviteCode.trim();
    if (code.isEmpty) return;

    await PendingProjectInviteStore.save(code);
    if (!context.mounted) return;

    if (!await isRiskDisclaimerAccepted()) {
      if (!context.mounted) return;
      context.go(AppRoutes.agreement);
      return;
    }

    if (!context.mounted) return;
    context.go(AppRoutes.projectInvitation(code));
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
