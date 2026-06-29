import 'package:vestie/features/project_pot/domain/entities/project_pot_entity.dart';

import 'borrow_request_entity.dart';
import 'project_detail_entity.dart';

extension ProjectDetailEntityPot on ProjectDetailEntity {
  /// Merges `GET /projects/{id}/borrow-requests` into project detail.
  ProjectDetailEntity withBorrowRequests(List<BorrowRequestEntity> requests) {
    return ProjectDetailEntity(
      id: id,
      name: name,
      category: category,
      status: status,
      goalAmount: goalAmount,
      currentAmount: currentAmount,
      contributorCount: contributorCount,
      endsIn: endsIn,
      announcement: announcement,
      announcements: announcements,
      members: members,
      borrowRequests: requests,
      viewerRole: viewerRole,
      membershipId: membershipId,
      borrowLimitAmount: borrowLimitAmount,
      repaymentWindowDays: repaymentWindowDays,
      repaymentGraceDays: repaymentGraceDays,
      contributionsAreNonRefundable: contributionsAreNonRefundable,
      displayStatusLabel: displayStatusLabel,
      projectLifecycleState: projectLifecycleState,
      projectBannerStatus: projectBannerStatus,
      votingStatus: votingStatus,
      detailUserRole: detailUserRole,
      voting: voting,
      hasWeek11ProjectDetailEnvelope: hasWeek11ProjectDetailEnvelope,
      borrowingEnabled: borrowingEnabled,
      pendingJoinRequestCount: pendingJoinRequestCount,
      projectInviteCode: projectInviteCode,
      roiPercentage: roiPercentage,
      joinApprovalRequired: joinApprovalRequired,
      minimumContributionAmount: minimumContributionAmount,
      penaltyPercentage: penaltyPercentage,
      successVoteWindowHours: successVoteWindowHours,
      hasActiveSuccessVote: hasActiveSuccessVote,
      activeClosureVote: activeClosureVote,
      invites: invites,
      hasCoLeader: hasCoLeader,
    );
  }

  /// Applies `GET /projects/{id}/pot` (or SignalR payload) to raised amount only.
  /// VFF state comes from `GET /projects/{id}` members — not pot.
  ProjectDetailEntity withProjectPot(ProjectPotEntity pot) {
    final raised = pot.potAmount > 0 ? pot.potAmount : currentAmount;

    return ProjectDetailEntity(
      id: id,
      name: name,
      category: category,
      status: status,
      goalAmount: goalAmount,
      currentAmount: raised,
      contributorCount: pot.contributorCount,
      endsIn: endsIn,
      announcement: announcement,
      announcements: announcements,
      members: members,
      borrowRequests: borrowRequests,
      viewerRole: viewerRole,
      membershipId: membershipId,
      borrowLimitAmount: borrowLimitAmount,
      repaymentWindowDays: repaymentWindowDays,
      repaymentGraceDays: repaymentGraceDays,
      contributionsAreNonRefundable: contributionsAreNonRefundable,
      displayStatusLabel: displayStatusLabel,
      projectLifecycleState: projectLifecycleState,
      projectBannerStatus: projectBannerStatus,
      votingStatus: votingStatus,
      detailUserRole: detailUserRole,
      voting: voting,
      hasWeek11ProjectDetailEnvelope: hasWeek11ProjectDetailEnvelope,
      borrowingEnabled: borrowingEnabled,
      pendingJoinRequestCount: pendingJoinRequestCount,
      projectInviteCode: projectInviteCode,
      roiPercentage: roiPercentage,
      joinApprovalRequired: joinApprovalRequired,
      minimumContributionAmount: minimumContributionAmount,
      penaltyPercentage: penaltyPercentage,
      successVoteWindowHours: successVoteWindowHours,
      hasActiveSuccessVote: hasActiveSuccessVote,
      activeClosureVote: activeClosureVote,
      invites: invites,
      hasCoLeader: hasCoLeader,
    );
  }

  ProjectDetailEntity withRealtimePotHint({
    required String projectId,
    double? potAmount,
    int? contributorCount,
  }) {
    if (id != projectId) return this;
    if (potAmount == null || potAmount <= 0) return this;
    return ProjectDetailEntity(
      id: id,
      name: name,
      category: category,
      status: status,
      goalAmount: goalAmount,
      currentAmount: potAmount,
      contributorCount: contributorCount ?? this.contributorCount,
      endsIn: endsIn,
      announcement: announcement,
      announcements: announcements,
      members: members,
      borrowRequests: borrowRequests,
      viewerRole: viewerRole,
      membershipId: membershipId,
      borrowLimitAmount: borrowLimitAmount,
      repaymentWindowDays: repaymentWindowDays,
      repaymentGraceDays: repaymentGraceDays,
      contributionsAreNonRefundable: contributionsAreNonRefundable,
      displayStatusLabel: displayStatusLabel,
      projectLifecycleState: projectLifecycleState,
      projectBannerStatus: projectBannerStatus,
      votingStatus: votingStatus,
      detailUserRole: detailUserRole,
      voting: voting,
      hasWeek11ProjectDetailEnvelope: hasWeek11ProjectDetailEnvelope,
      borrowingEnabled: borrowingEnabled,
      pendingJoinRequestCount: pendingJoinRequestCount,
      projectInviteCode: projectInviteCode,
      roiPercentage: roiPercentage,
      joinApprovalRequired: joinApprovalRequired,
      minimumContributionAmount: minimumContributionAmount,
      penaltyPercentage: penaltyPercentage,
      successVoteWindowHours: successVoteWindowHours,
      hasActiveSuccessVote: hasActiveSuccessVote,
      activeClosureVote: activeClosureVote,
      invites: invites,
      hasCoLeader: hasCoLeader,
    );
  }
}
