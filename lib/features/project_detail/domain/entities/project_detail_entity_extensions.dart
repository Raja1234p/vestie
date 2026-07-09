import 'member_entity.dart';
import 'member_entity_extensions.dart';
import 'project_detail_entity.dart';

extension ProjectDetailEntityViewer on ProjectDetailEntity {
  /// API user id for the signed-in viewer on this project.
  String? get viewerUserId {
    final viewerMembershipId = membershipId.trim();
    if (viewerMembershipId.isEmpty) return null;
    for (final member in members) {
      if (member.membershipId.trim() != viewerMembershipId) continue;
      final uid = member.apiUserId.trim();
      return uid.isEmpty ? null : uid;
    }
    return null;
  }
}

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
      totalContributed: totalContributed,
      contributorCount: contributorCount,
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
      projectLifecycleState: projectLifecycleState,
      projectBannerStatus: projectBannerStatus,
      votingStatus: votingStatus,
      detailUserRole: detailUserRole,
      voting: voting,
      hasWeek11ProjectDetailEnvelope: hasWeek11ProjectDetailEnvelope,
      apiCanStopContributions: apiCanStopContributions,
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
      coverImageUrl: coverImageUrl,
      images: images,
      membersPagination: membersPagination,
      invitesPagination: invitesPagination,
      announcementsPagination: announcementsPagination,
    );
  }
}
