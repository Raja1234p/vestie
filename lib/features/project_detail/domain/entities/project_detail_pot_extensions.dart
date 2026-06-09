import 'package:vestie/features/project_pot/domain/entities/project_pot_entity.dart';

import 'borrow_request_entity.dart';
import 'member_entity_extensions.dart';
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
      borrowingEnabled: borrowingEnabled,
      pendingJoinRequestCount: pendingJoinRequestCount,
      projectInviteCode: projectInviteCode,
      roiPercentage: roiPercentage,
      joinApprovalRequired: joinApprovalRequired,
      minimumContributionAmount: minimumContributionAmount,
      penaltyPercentage: penaltyPercentage,
      successVoteWindowHours: successVoteWindowHours,
      hasActiveSuccessVote: hasActiveSuccessVote,
      invites: invites,
      hasCoLeader: hasCoLeader,
    );
  }

  /// Applies `GET /projects/{id}/pot` (or SignalR payload) to raised amount + VFF badges.
  ProjectDetailEntity withProjectPot(ProjectPotEntity pot) {
    final vffIds = pot.vffMemberUserIds.map((e) => e.trim()).toSet();

    final updatedMembers = members
        .map((member) {
          final isPotVff = vffIds.contains(member.apiUserId);
          if (!isPotVff) return member;
          return member.copyWith(vffAdded: true);
        })
        .toList(growable: false);

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
      members: updatedMembers,
      borrowRequests: borrowRequests,
      viewerRole: viewerRole,
      membershipId: membershipId,
      borrowLimitAmount: borrowLimitAmount,
      repaymentWindowDays: repaymentWindowDays,
      repaymentGraceDays: repaymentGraceDays,
      contributionsAreNonRefundable: contributionsAreNonRefundable,
      displayStatusLabel: displayStatusLabel,
      borrowingEnabled: borrowingEnabled,
      pendingJoinRequestCount: pendingJoinRequestCount,
      projectInviteCode: projectInviteCode,
      roiPercentage: roiPercentage,
      joinApprovalRequired: joinApprovalRequired,
      minimumContributionAmount: minimumContributionAmount,
      penaltyPercentage: penaltyPercentage,
      successVoteWindowHours: successVoteWindowHours,
      hasActiveSuccessVote: hasActiveSuccessVote,
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
      borrowingEnabled: borrowingEnabled,
      pendingJoinRequestCount: pendingJoinRequestCount,
      projectInviteCode: projectInviteCode,
      roiPercentage: roiPercentage,
      joinApprovalRequired: joinApprovalRequired,
      minimumContributionAmount: minimumContributionAmount,
      penaltyPercentage: penaltyPercentage,
      successVoteWindowHours: successVoteWindowHours,
      hasActiveSuccessVote: hasActiveSuccessVote,
      invites: invites,
      hasCoLeader: hasCoLeader,
    );
  }
}
