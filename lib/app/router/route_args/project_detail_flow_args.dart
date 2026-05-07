class BorrowRequestsRouteArgs<T> {
  final List<T> requests;
  final bool isLeaderMode;
  final String projectId;

  const BorrowRequestsRouteArgs({
    required this.requests,
    required this.projectId,
    this.isLeaderMode = false,
  });
}

class JoinRequestsRouteArgs {
  final String projectId;

  const JoinRequestsRouteArgs({required this.projectId});
}

class MemberDetailRouteArgs<T> {
  final T member;
  final String projectId;
  final String projectName;
  final bool isLeaderView;

  const MemberDetailRouteArgs({
    required this.member,
    required this.projectId,
    required this.projectName,
    this.isLeaderView = false,
  });
}

class MemberPenaltyActionRouteArgs<T> {
  final T member;
  final String projectId;

  const MemberPenaltyActionRouteArgs({
    required this.member,
    required this.projectId,
  });
}

class MarkSuccessfulRouteArgs {
  final String projectId;
  final int memberCount;

  const MarkSuccessfulRouteArgs({
    required this.projectId,
    required this.memberCount,
  });
}

class CancelProjectRouteArgs {
  final String projectId;
  final String projectName;
  final int membersWithUnpaidBorrows;

  const CancelProjectRouteArgs({
    required this.projectId,
    required this.projectName,
    this.membersWithUnpaidBorrows = 0,
  });
}

class ProjectCancelledRouteArgs {
  final String projectName;

  const ProjectCancelledRouteArgs({required this.projectName});
}

/// Full-screen join / mark-vote outcomes (member flows).
enum UserStatusFlowKind {
  joinApproved,
  joinRejected,
  markVotedSuccess,
  markVotedIncomplete,
}

class UserStatusFlowArgs {
  final String projectName;
  final UserStatusFlowKind kind;

  const UserStatusFlowArgs({
    required this.projectName,
    required this.kind,
  });
}

/// Member success-vote screen (leader has started a vote).
class UserSuccessVoteArgs {
  final String? projectId;
  final String projectName;
  final double goalAmount;
  final int memberCount;
  final double totalRaised;
  final String deadlineLabel;
  final int daysRemaining;

  const UserSuccessVoteArgs({
    this.projectId,
    required this.projectName,
    required this.goalAmount,
    required this.memberCount,
    required this.totalRaised,
    required this.deadlineLabel,
    required this.daysRemaining,
  });
}

