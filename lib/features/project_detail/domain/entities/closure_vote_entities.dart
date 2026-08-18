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
  noVotes,
}

/// API wire values for [ClosureVoteType] / [ClosureVoteOutcome].
abstract final class ClosureVoteApiValues {
  static const voteTypeSuccess = 'SuccessVote';
  static const voteTypeStopContributions = 'StopContributionsVote';
  static const voteTypeFinalClosure = 'FinalClosureVote';
  static const outcomeSuccess = 'Success';
  static const outcomeInvestmentStarted = 'InvestmentStarted';
  static const outcomeRefund = 'Refund';
  static const outcomeDisputed = 'Disputed';
  static const outcomeNoVotes = 'NoVotes';
  static const votingStatusNotStarted = 'not_started';
}

/// Majority passed — maps Week 10 `outcome` from detail or finalize payloads.
bool isClosureVoteOutcomeApproved(ClosureVoteOutcome outcome) {
  return switch (outcome) {
    ClosureVoteOutcome.success => true,
    ClosureVoteOutcome.investmentStarted => true,
    ClosureVoteOutcome.refund => false,
    ClosureVoteOutcome.disputed => false,
    ClosureVoteOutcome.noVotes => false,
  };
}

ClosureVoteType parseClosureVoteType(String? raw) {
  switch (raw?.trim()) {
    case ClosureVoteApiValues.voteTypeStopContributions:
      return ClosureVoteType.stopContributionsVote;
    case ClosureVoteApiValues.voteTypeFinalClosure:
      return ClosureVoteType.finalClosureVote;
    case ClosureVoteApiValues.voteTypeSuccess:
    default:
      return ClosureVoteType.successVote;
  }
}

ClosureVoteOutcome parseClosureVoteOutcome(String? raw) {
  switch (raw?.trim()) {
    case ClosureVoteApiValues.outcomeInvestmentStarted:
      return ClosureVoteOutcome.investmentStarted;
    case ClosureVoteApiValues.outcomeRefund:
      return ClosureVoteOutcome.refund;
    case ClosureVoteApiValues.outcomeDisputed:
      return ClosureVoteOutcome.disputed;
    case ClosureVoteApiValues.outcomeNoVotes:
      return ClosureVoteOutcome.noVotes;
    case ClosureVoteApiValues.outcomeSuccess:
    default:
      return ClosureVoteOutcome.success;
  }
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

/// Response from `POST …/closure-voting/cancel`.
class CancelClosureVoteResultEntity {
  final bool cancelled;
  final String projectId;
  final String votingStatusRaw;

  const CancelClosureVoteResultEntity({
    this.cancelled = true,
    this.projectId = '',
    this.votingStatusRaw = '',
  });

  bool get restoredToNotStarted {
    final status = votingStatusRaw.trim().toLowerCase();
    return cancelled &&
        (status.isEmpty || status == ClosureVoteApiValues.votingStatusNotStarted);
  }
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
