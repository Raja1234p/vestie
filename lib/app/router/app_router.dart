import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/app_auth_session.dart';
import '../../core/constants/app_strings.dart';
import 'app_routes.dart';
import 'project_invite_route_guard.dart';
import 'session_auth_redirect.dart';
import 'route_groups/core_routes.dart';
import 'route_groups/profile_wallet_routes.dart';
import 'route_groups/project_routes.dart';
import 'route_groups/create_project_member_flow_routes.dart';
import 'route_groups/user_vff_routes.dart';

class AppRouter {
  static Widget _invalidRouteScreen() =>
      const Scaffold(body: Center(child: Text(AppStrings.routeNotFound)));

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: AppAuthSession.instance,
    redirect: (context, state) async {
      final inviteRedirect = await ProjectInviteRouteGuard.redirect(state);
      if (inviteRedirect != null) return inviteRedirect;
      return SessionAuthRedirect.redirect(state);
    },
    routes: [
      ...buildCoreRoutes(),
      ...buildProfileWalletRoutes(),
      ...buildProjectRoutes(invalidRouteScreen: _invalidRouteScreen),
      ...buildCreateProjectMemberFlowRoutes(),
      ...buildUserVffRoutes(invalidRouteScreen: _invalidRouteScreen),
    ],
    errorBuilder: (context, _) =>
        const Scaffold(body: Center(child: Text(AppStrings.routeNotFound))),
  );
}
