import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/user_vff_flow_args.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/pages/user_vff_group_invitations_screen.dart';
import 'package:vestie/user/features/vff/presentation/pages/user_vff_hub_screen.dart';
import 'package:vestie/user/features/vff/presentation/pages/user_vff_invites_sent_screen.dart';
import 'package:vestie/user/features/vff/presentation/pages/user_vff_profile_screen.dart';
import 'package:vestie/user/features/vff/presentation/pages/user_vff_vff_requests_screen.dart';

import 'route_group_types.dart';

List<RouteBase> buildUserVffRoutes({
  required InvalidRouteBuilder invalidRouteScreen,
}) {
  return [
    GoRoute(
      path: AppRoutes.userVffMain,
      builder: (context, state) {
        UserVffHubUiModel hub = UserVffHubUiModel.demoFilled();
        final extra = state.extra;
        if (extra is UserVffHubRouteArgs) hub = extra.hub;
        return UserVffHubScreen(hub: hub);
      },
    ),
    GoRoute(
      path: AppRoutes.userVffVffRequestsAll,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is List<UserVffIncomingRequestUi>) {
          return UserVffVffRequestsScreen(rows: extra);
        }
        if (extra is List) {
          final rows = extra.whereType<UserVffIncomingRequestUi>().toList();
          if (rows.length == extra.length) {
            return UserVffVffRequestsScreen(rows: rows);
          }
        }
        return invalidRouteScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.userVffGroupInvitesAll,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is List<UserVffGroupInviteUi>) {
          return UserVffGroupInvitationsScreen(rows: extra);
        }
        if (extra is List) {
          final rows = extra.whereType<UserVffGroupInviteUi>().toList();
          if (rows.length == extra.length) {
            return UserVffGroupInvitationsScreen(rows: rows);
          }
        }
        return invalidRouteScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.userVffProfile,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! UserVffProfileRouteArgs) {
          return invalidRouteScreen();
        }
        return UserVffProfileScreen(profile: extra.profile);
      },
    ),
    GoRoute(
      path: AppRoutes.userVffInvitesSent,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! UserVffInvitesSentRouteArgs) {
          return invalidRouteScreen();
        }
        return UserVffInvitesSentScreen(
          inviteCount: extra.inviteCount,
          projectName: extra.projectName,
        );
      },
    ),
  ];
}
