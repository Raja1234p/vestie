import 'package:vestie/user/features/home/domain/entities/project.dart';

import 'closure_vote_entities.dart';
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

  /// Refund-oriented outcome (Refund / cancelled project).
  bool get showsClosureVoteRefundOutcome {
    if (voting?.outcome == ClosureVoteOutcome.refund) return true;
    if (projectBannerStatus == ProjectDetailBannerStatus.cancelled) return true;
    return displayStatusLabel.toLowerCase().trim().contains('refund');
  }

  bool get hasCompletedVoteTallies {
    final summary = voting;
    if (summary == null) return false;
    return summary.agreedCount + summary.disagreedCount > 0;
  }

  bool get showsCompletedProjectVoteOutcome =>
      isProjectDetailCompleted || hasFinalizedClosureVoteOutcome;
}
