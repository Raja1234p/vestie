/// Week 11+ top-level `projectStatus` on `GET /projects/{id}` — detail banner.
enum ProjectDetailBannerStatus {
  ongoing,
  completed,
  cancelled,
}

/// Week 11+ `votingStatus` — drives the voting card on project detail.
enum ProjectVotingStatus {
  notStarted,
  pending,
  done,
}

/// Week 11+ top-level `userRole` — prefer over nested `project.viewerRole`.
enum ProjectDetailUserRole {
  leader,
  coLeader,
  member,
}

/// Week 11+ `voting` object when `votingStatus` is `pending` or `done`.
class ProjectVotingSummaryEntity {
  final DateTime startedAtUtc;
  final DateTime deadlineAtUtc;
  final int agreedCount;
  final int disagreedCount;
  final int pendingCount;
  final bool hasVoted;
  final bool isFinalized;

  const ProjectVotingSummaryEntity({
    required this.startedAtUtc,
    required this.deadlineAtUtc,
    required this.agreedCount,
    required this.disagreedCount,
    required this.pendingCount,
    this.hasVoted = false,
    this.isFinalized = false,
  });

  int get totalVotes => agreedCount + disagreedCount + pendingCount;

  double get agreedPercent =>
      totalVotes > 0 ? agreedCount / totalVotes : 0;

  double get disagreedPercent =>
      totalVotes > 0 ? disagreedCount / totalVotes : 0;

  double get pendingPercent =>
      totalVotes > 0 ? pendingCount / totalVotes : 0;
}

ProjectDetailBannerStatus parseProjectDetailBannerStatus(String? raw) {
  return switch (raw?.toLowerCase().trim()) {
    'completed' => ProjectDetailBannerStatus.completed,
    'cancelled' => ProjectDetailBannerStatus.cancelled,
    _ => ProjectDetailBannerStatus.ongoing,
  };
}

ProjectVotingStatus parseProjectVotingStatus(String? raw) {
  return switch (raw?.toLowerCase().trim()) {
    'pending' => ProjectVotingStatus.pending,
    'done' => ProjectVotingStatus.done,
    _ => ProjectVotingStatus.notStarted,
  };
}

ProjectDetailUserRole parseProjectDetailUserRole(String? raw) {
  return switch (raw?.toLowerCase().trim()) {
    'leader' => ProjectDetailUserRole.leader,
    'co_leader' => ProjectDetailUserRole.coLeader,
    _ => ProjectDetailUserRole.member,
  };
}

ProjectDetailUserRole projectDetailUserRoleFromViewerRole(String? viewerRole) {
  final normalized = viewerRole?.toLowerCase().trim() ?? '';
  if (normalized.contains('groupleader') || normalized == 'leader') {
    return ProjectDetailUserRole.leader;
  }
  if (normalized.contains('coleader') || normalized.contains('co_leader')) {
    return ProjectDetailUserRole.coLeader;
  }
  return ProjectDetailUserRole.member;
}

ProjectDetailBannerStatus projectDetailBannerStatusFromLifecycleState(
  String lifecycleState,
) {
  final s = lifecycleState.toLowerCase().trim();
  if (s == 'completed') return ProjectDetailBannerStatus.completed;
  if (s == 'cancelled') return ProjectDetailBannerStatus.cancelled;
  return ProjectDetailBannerStatus.ongoing;
}
