import 'closure_vote_entities.dart';

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

/// Per-member row on `GET /projects/{id}` → `voting.memberVotes[]`.
enum ProjectMemberVoteStatus {
  agreed,
  disagreed,
  waiting,
}

class ProjectVotingMemberVoteEntity {
  final String membershipId;
  final String userId;
  final String displayName;
  final ProjectMemberVoteStatus status;

  const ProjectVotingMemberVoteEntity({
    required this.membershipId,
    required this.userId,
    required this.displayName,
    required this.status,
  });
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
  final List<ProjectVotingMemberVoteEntity> memberVotes;
  final ClosureVoteType? voteType;
  final ClosureVoteOutcome? outcome;
  final bool? isApproved;
  final int? eligibleVoterCount;
  final bool? canContinueContributions;
  final String? distributionStatus;

  /// API `voting.viewerRefundAmount` — viewer refund on cancelled/refund outcomes.
  final double viewerRefundAmount;

  const ProjectVotingSummaryEntity({
    required this.startedAtUtc,
    required this.deadlineAtUtc,
    required this.agreedCount,
    required this.disagreedCount,
    required this.pendingCount,
    this.hasVoted = false,
    this.isFinalized = false,
    this.memberVotes = const [],
    this.voteType,
    this.outcome,
    this.isApproved,
    this.eligibleVoterCount,
    this.canContinueContributions,
    this.distributionStatus,
    this.viewerRefundAmount = 0,
  });

  /// Backend `voting.isApproved` or derived from [outcome].
  bool? get resolvedIsApproved {
    if (isApproved != null) return isApproved;
    if (outcome != null) {
      return isClosureVoteOutcomeApproved(outcome!);
    }
    return null;
  }

  bool get hasOutcomeEnvelope =>
      voteType != null || outcome != null || isApproved != null;

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

ProjectMemberVoteStatus parseProjectMemberVoteStatus(String? raw) {
  return switch (raw?.toLowerCase().trim()) {
    'agreed' || 'agree' || 'yes' => ProjectMemberVoteStatus.agreed,
    'disagreed' || 'disagree' || 'no' => ProjectMemberVoteStatus.disagreed,
    _ => ProjectMemberVoteStatus.waiting,
  };
}
