import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import 'closure_vote_entities.dart';
import 'closure_vote_participation_extensions.dart';
import 'project_detail_entity.dart';
import 'project_detail_voting_entities.dart';

extension ProjectDetailEntityCompletedOutcome on ProjectDetailEntity {
  /// Completed or cancelled — show closure vote outcome UI (approved / rejected / refund).
  bool get isProjectDetailCompleted =>
      status == ProjectStatus.completed ||
      projectBannerStatus == ProjectDetailBannerStatus.completed ||
      projectBannerStatus == ProjectDetailBannerStatus.cancelled;

  /// Finalized vote with explicit outcome envelope from `GET /projects/{id}` → `voting`.
  bool get hasFinalizedClosureVoteOutcome {
    final summary = voting;
    if (summary == null || !summary.isFinalized) return false;
    if (!summary.hasOutcomeEnvelope) return false;
    return summary.agreedCount + summary.disagreedCount > 0 ||
        summary.outcome != null ||
        summary.isApproved != null;
  }

  /// Majority closure vote passed (Success / InvestmentStarted).
  bool get isClosureVoteOutcomeApproved {
    final fromVoting = voting?.resolvedIsApproved;
    if (fromVoting != null) return fromVoting;
    if (projectBannerStatus == ProjectDetailBannerStatus.cancelled) return false;
    final status = displayStatusLabel.toLowerCase().trim();
    if (status.contains('not approved') ||
        status.contains('reject') ||
        status.contains('refund') ||
        status.contains('cancel')) {
      return false;
    }
    return true;
  }

  /// Investment stop-contributions vote passed with **Refund Me** majority only.
  /// Final closure rejection → Project Not Approved; keep-contributing rejection → Vote Not Passed.
  bool get showsClosureVoteRefundOutcome {
    if (!category.isInvestment) return false;
    if (voting?.voteType != ClosureVoteType.stopContributionsVote) return false;
    if (voting?.outcome == ClosureVoteOutcome.refund) return true;
    return displayStatusLabel.toLowerCase().trim().contains('refund');
  }

  bool get hasCompletedVoteTallies {
    final summary = voting;
    if (summary == null) return false;
    return summary.agreedCount + summary.disagreedCount > 0;
  }

  /// Full-screen vote outcome — not shown during investment distribute/returns phase.
  /// Investment final-closure with no votes → Distribute Funds (same as No Dispute).
  bool get showsCompletedProjectVoteOutcome {
    if (isInvestmentFinalClosureNoParticipation) return false;
    if (!(isProjectDetailCompleted || hasFinalizedClosureVoteOutcome)) {
      return false;
    }
    return !showsInvestmentDistributionActions;
  }

  /// Investment mark-successful / final closure vote passed (not stop-contributions).
  bool get isApprovedInvestmentFinalClosureOutcome {
    if (!category.isInvestment || !isClosureVoteOutcomeApproved) {
      return false;
    }
    final voteType = voting?.voteType;
    if (voteType == ClosureVoteType.stopContributionsVote) return false;
    if (voteType == ClosureVoteType.finalClosureVote) return true;
    if (voting?.outcome == ClosureVoteOutcome.investmentStarted) return true;
    return investmentContributionsAreClosed;
  }

  /// Outcome screen headline — investment final success uses [totalContributed] only.
  double get closureVoteOutcomeAmountUsd {
    if (isApprovedInvestmentFinalClosureOutcome) {
      return totalContributed;
    }
    return raisedDisplayAmount;
  }
}
