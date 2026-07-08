import 'closure_vote_entities.dart';
import 'project_detail_entity.dart';
import 'project_detail_voting_entities.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

/// True when a finalized vote ended with zero Agreed and zero Disagreed casts.
bool isClosureVoteNoParticipation({
  required bool isFinalized,
  ClosureVoteOutcome? outcome,
  required int agreedCount,
  required int disagreedCount,
}) {
  if (!isFinalized) return false;
  if (outcome == ClosureVoteOutcome.noVotes) return true;
  return agreedCount == 0 && disagreedCount == 0;
}

extension ProjectVotingSummaryParticipation on ProjectVotingSummaryEntity {
  bool get isNoParticipation => isClosureVoteNoParticipation(
    isFinalized: isFinalized,
    outcome: outcome,
    agreedCount: agreedCount,
    disagreedCount: disagreedCount,
  );
}

extension ProjectDetailEntityClosureParticipation on ProjectDetailEntity {
  bool get isClosureVoteNoParticipation {
    final summary = voting;
    if (summary == null) return false;
    return summary.isNoParticipation;
  }

  /// Investment mark-successful / final-closure vote ended with no member votes.
  /// Treated like **No Dispute** — Distribute Funds / Investment Returns on detail.
  bool get isInvestmentFinalClosureNoParticipation {
    if (!category.isInvestment) return false;
    if (voting?.voteType != ClosureVoteType.finalClosureVote) return false;
    return isClosureVoteNoParticipation;
  }

  /// Show no-votes refund outcome (vacation, emergency, investment stop-contrib).
  bool get showsClosureVoteNoParticipationOutcome {
    if (!isClosureVoteNoParticipation) return false;
    if (isInvestmentFinalClosureNoParticipation) return false;
    return true;
  }
}

extension ProjectListClosureParticipation on Project {
  bool get isInvestmentFinalClosureNoParticipationFromList {
    if (!category.isInvestment) return false;
    if (parseClosureVoteType(lastVoteType) != ClosureVoteType.finalClosureVote) {
      return false;
    }
    return parseClosureVoteOutcome(lastVoteOutcome) ==
        ClosureVoteOutcome.noVotes;
  }

  bool get isClosureVoteNoParticipationFromList {
    if (lastVoteOutcome != null &&
        parseClosureVoteOutcome(lastVoteOutcome) ==
            ClosureVoteOutcome.noVotes) {
      return true;
    }
    return false;
  }
}
