import 'vff_enums.dart';

class VffProfileStatsEntity {
  final int joinedProjectsCount;
  final int contributionCount;
  final double totalContributedAmount;

  const VffProfileStatsEntity({
    this.joinedProjectsCount = 0,
    this.contributionCount = 0,
    this.totalContributedAmount = 0,
  });
}

class VffJoinedProjectEntity {
  final String projectId;
  final String name;
  final String? type;
  final VffProjectVisibility visibility;
  final String? state;
  final VffProjectJoinState joinState;
  final int memberCount;

  const VffJoinedProjectEntity({
    required this.projectId,
    required this.name,
    this.type,
    this.visibility = VffProjectVisibility.public,
    this.state,
    this.joinState = VffProjectJoinState.join,
    this.memberCount = 0,
  });
}

/// Connected VFF profile (`GET /users/me/vffs/{userId}`).
class VffConnectedProfileEntity {
  final String userId;
  final String fullName;
  final String? username;
  final String? profilePhotoUrl;
  final int mutualProjectsCount;
  final VffProfileStatsEntity stats;
  final List<VffJoinedProjectEntity> joinedProjects;

  const VffConnectedProfileEntity({
    required this.userId,
    required this.fullName,
    this.username,
    this.profilePhotoUrl,
    this.mutualProjectsCount = 0,
    required this.stats,
    this.joinedProjects = const [],
  });
}

/// Public / cross-project profile (`GET /users/{userId}/vff-profile`).
class VffPublicProfileEntity {
  final String userId;
  final String fullName;
  final String? username;
  final String? profilePhotoUrl;
  final bool isVffConnected;
  final VffProfileStatsEntity stats;
  final List<VffJoinedProjectEntity> joinedProjects;

  const VffPublicProfileEntity({
    required this.userId,
    required this.fullName,
    this.username,
    this.profilePhotoUrl,
    this.isVffConnected = false,
    required this.stats,
    this.joinedProjects = const [],
  });
}
