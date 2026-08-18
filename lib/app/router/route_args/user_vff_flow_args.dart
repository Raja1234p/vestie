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

/// Optional override for mocked hub lists (omit `extra` → live API).
/// Push taps use [requestsTab] so the incoming VFF request is visible.
class UserVffHubRouteArgs {
  static const int myVffsTabIndex = 0;
  static const int requestsTabIndex = 1;

  final UserVffHubUiModel? hub;
  final int initialTabIndex;

  const UserVffHubRouteArgs({
    this.hub,
    this.initialTabIndex = myVffsTabIndex,
  });

  factory UserVffHubRouteArgs.defaults() =>
      UserVffHubRouteArgs(hub: UserVffHubUiModel.demoFilled());

  factory UserVffHubRouteArgs.requestsTab() =>
      const UserVffHubRouteArgs(initialTabIndex: requestsTabIndex);
}

/// Popped from [UserVffProfileScreen] after a successful VFF mutation.
enum UserVffProfilePopResult { connectionRemoved, vffRequestSent }

/// Opens peer profile (`user_vff_profile_screen.dart`).
class UserVffProfileRouteArgs {
  final String userId;
  final bool isConnectedProfile;
  final String? projectId;
  final UserVffProfileUiModel? previewProfile;

  const UserVffProfileRouteArgs({
    required this.userId,
    this.isConnectedProfile = false,
    this.projectId,
    this.previewProfile,
  });

  factory UserVffProfileRouteArgs.preview(UserVffProfileUiModel profile) {
    return UserVffProfileRouteArgs(
      userId: profile.id,
      isConnectedProfile:
          profile.footerMode == UserVffProfileFooterMode.followingSheet,
      previewProfile: profile,
    );
  }
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
