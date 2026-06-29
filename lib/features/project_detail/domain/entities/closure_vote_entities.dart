import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import 'leader_voting_flow_kind.dart';

/// Week 10 `voteType` values for closure voting.
enum ClosureVoteType {
  successVote,
  stopContributionsVote,
  finalClosureVote,
}

/// Week 10 `vote` / `callerVote` values.
enum ClosureVoteValue {
  yes,
  no,
}

/// Week 10 vote window status (`status: Open`, etc.).
enum ClosureVoteStatus {
  open,
  closed,
}

/// Week 10 finalize `outcome`.
enum ClosureVoteOutcome {
  success,
  investmentStarted,
  refund,
  disputed,
}

/// Active vote payload from `GET /projects/{id}/closure-voting/active`.
class ActiveClosureVoteEntity {
  final String closureVoteId;
  final ClosureVoteType voteType;
  final ClosureVoteStatus status;
  final DateTime votingDeadlineUtc;
  final int daysRemaining;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;
  final double goalAmount;
  final double totalRaised;
  final int memberCount;
  final ClosureVoteValue? callerVote;
  final bool callerIsGroupLeader;

  const ActiveClosureVoteEntity({
    required this.closureVoteId,
    required this.voteType,
    required this.status,
    required this.votingDeadlineUtc,
    required this.daysRemaining,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
    required this.goalAmount,
    required this.totalRaised,
    required this.memberCount,
    this.callerVote,
    this.callerIsGroupLeader = false,
  });

  bool get isOpen => status == ClosureVoteStatus.open;

  bool get callerHasAgreed => callerVote == ClosureVoteValue.yes;

  bool get callerHasDisagreed => callerVote == ClosureVoteValue.no;

  bool get callerHasNotVoted => callerVote == null;

  Duration get remainingDuration {
    final diff = votingDeadlineUtc.difference(DateTime.now().toUtc());
    return diff.isNegative ? Duration.zero : diff;
  }
}

/// Response from `POST …/closure-voting/open`.
class OpenClosureVoteEntity {
  final String closureVoteId;
  final ClosureVoteType voteType;
  final DateTime votingDeadlineUtc;
  final int votingWindowDays;
  final ClosureVoteStatus status;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;

  const OpenClosureVoteEntity({
    required this.closureVoteId,
    required this.voteType,
    required this.votingDeadlineUtc,
    required this.votingWindowDays,
    required this.status,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
  });
}

/// Response from `POST …/closure-voting/vote`.
class CastClosureVoteResultEntity {
  final String closureVoteId;
  final ClosureVoteValue callerVote;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;

  const CastClosureVoteResultEntity({
    required this.closureVoteId,
    required this.callerVote,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
  });
}

/// Response from `POST …/closure-voting/finalize`.
class FinalizeClosureVoteResultEntity {
  final String closureVoteId;
  final ClosureVoteType voteType;
  final ClosureVoteOutcome outcome;
  final int thumbsUp;
  final int thumbsDown;
  final int notYetVoted;
  final String projectStatus;

  const FinalizeClosureVoteResultEntity({
    required this.closureVoteId,
    required this.voteType,
    required this.outcome,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notYetVoted,
    required this.projectStatus,
  });
}

/// Maps leader UI flows + project category to Week 10 `voteType`.
ClosureVoteType resolveClosureVoteType({
  required LeaderVotingFlowKind flowKind,
  required ProjectCategory category,
}) {
  return switch (flowKind) {
    LeaderVotingFlowKind.stopContributions => ClosureVoteType.stopContributionsVote,
    LeaderVotingFlowKind.markProjectSuccessful =>
      category.isInvestment
          ? ClosureVoteType.finalClosureVote
          : ClosureVoteType.successVote,
  };
}
