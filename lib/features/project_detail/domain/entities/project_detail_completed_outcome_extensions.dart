import 'package:vestie/user/features/home/domain/entities/project.dart';

import 'project_detail_entity.dart';
import 'project_detail_voting_entities.dart';

extension ProjectDetailEntityCompletedOutcome on ProjectDetailEntity {
  /// Completed or cancelled — show closure vote outcome UI (approved / rejected / refund).
  bool get isProjectDetailCompleted =>
      status == ProjectStatus.completed ||
      projectBannerStatus == ProjectDetailBannerStatus.completed ||
      projectBannerStatus == ProjectDetailBannerStatus.cancelled;

  /// Majority closure vote passed (Success / InvestmentStarted).
  bool get isClosureVoteOutcomeApproved {
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
    if (projectBannerStatus == ProjectDetailBannerStatus.cancelled) return true;
    return displayStatusLabel.toLowerCase().trim().contains('refund');
  }

  bool get hasCompletedVoteTallies {
    final summary = voting;
    if (summary == null) return false;
    return summary.agreedCount + summary.disagreedCount > 0;
  }

  bool get showsCompletedProjectVoteOutcome => isProjectDetailCompleted;
}
