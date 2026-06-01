import 'member_entity.dart';
import 'member_entity_extensions.dart';
import 'project_detail_entity.dart';

extension ProjectDetailEntityMemberUpdates on ProjectDetailEntity {
  ProjectDetailEntity withUpdatedMember(
    MemberEntity target,
    MemberEntity Function(MemberEntity current) update,
  ) {
    final updatedMembers = members
        .map((m) => m.matchesIdentity(target) ? update(m) : m)
        .toList(growable: false);
    return ProjectDetailEntity(
      id: id,
      name: name,
      category: category,
      status: status,
      goalAmount: goalAmount,
      currentAmount: currentAmount,
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
}
