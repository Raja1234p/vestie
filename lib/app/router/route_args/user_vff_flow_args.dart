/// GoRouter extras for Verified Friends & Family (VFF) user journeys.
///
/// Flow map:
/// - Home → heart → `AppRoutes.userVffMain` hub (`UserVffHubRouteArgs` optional).
/// - Hub “See all” → full list routes with typed `List` extras.
/// - Member / invite paths → `AppRoutes.userVffProfile` (`UserVffProfileRouteArgs`).
/// - Accept / Join success → `AppRoutes.userVffInvitesSent` (`UserVffInvitesSentRouteArgs`).
library;

import 'package:vestie/user/features/vff/presentation/models/user_vff_hub_ui_model.dart';
import 'package:vestie/user/features/vff/presentation/models/user_vff_profile_ui_model.dart';

/// Optional override for mocked hub lists (omit `extra` → demo snapshot).
class UserVffHubRouteArgs {
  final UserVffHubUiModel hub;

  const UserVffHubRouteArgs({required this.hub});

  factory UserVffHubRouteArgs.defaults() =>
      UserVffHubRouteArgs(hub: UserVffHubUiModel.demoFilled());
}

/// Opens peer profile (`user_vff_profile_screen.dart`).
class UserVffProfileRouteArgs {
  final UserVffProfileUiModel profile;

  const UserVffProfileRouteArgs({required this.profile});
}

/// “Invites Sent!” confirmation (`user_vff_invites_sent_screen.dart`).
class UserVffInvitesSentRouteArgs {
  final int inviteCount;
  final String projectName;

  const UserVffInvitesSentRouteArgs({
    required this.inviteCount,
    required this.projectName,
  });
}
