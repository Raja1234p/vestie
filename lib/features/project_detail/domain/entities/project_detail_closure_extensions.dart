import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import 'closure_vote_entities.dart';
import 'leader_voting_flow_kind.dart';
import 'project_detail_entity.dart';
import 'project_detail_voting_entities.dart';

extension ProjectDetailEntityClosureVote on ProjectDetailEntity {
  ProjectDetailEntity withActiveClosureVote(ActiveClosureVoteEntity? vote) {
    return _copy(
      hasActiveSuccessVote: vote?.isOpen ?? false,
      activeClosureVote: vote,
    );
  }

  /// Builds a synthetic [ActiveClosureVoteEntity] from Week 11 `voting` for legacy screens.
  ProjectDetailEntity withSyntheticClosureVoteFromDetailVoting() {
    if (!votingIsInProgress || voting == null) return this;

    final summary = voting!;
    final now = DateTime.now().toUtc();
    final daysRemaining = summary.deadlineAtUtc.isAfter(now)
        ? summary.deadlineAtUtc.difference(now).inDays
        : 0;

    final synthetic = ActiveClosureVoteEntity(
      closureVoteId: 'detail-voting',
      voteType: _inferClosureVoteType(),
      status: votingStatus == ProjectVotingStatus.done
          ? ClosureVoteStatus.closed
          : ClosureVoteStatus.open,
      votingDeadlineUtc: summary.deadlineAtUtc,
      daysRemaining: daysRemaining,
      thumbsUp: summary.agreedCount,
      thumbsDown: summary.disagreedCount,
      notYetVoted: summary.pendingCount,
      goalAmount: goalAmount,
      totalRaised: currentAmount,
      memberCount: members.isNotEmpty ? members.length : summary.totalVotes,
      callerVote: _callerVoteFromSummary(summary),
      callerIsGroupLeader: isDetailLeader,
    );

    return _copy(
      hasActiveSuccessVote: true,
      activeClosureVote: synthetic,
    );
  }

  ClosureVoteType _inferClosureVoteType() {
    if (category.isInvestment) {
      final state = projectLifecycleState.toLowerCase().trim();
      if (state == 'funded' ||
          displayStatusLabel.toLowerCase().contains('funded')) {
        return ClosureVoteType.finalClosureVote;
      }
      return ClosureVoteType.stopContributionsVote;
    }
    return ClosureVoteType.successVote;
  }

  ClosureVoteValue? _callerVoteFromSummary(ProjectVotingSummaryEntity summary) {
    if (!(isDetailMember || isDetailCoLeader) || !summary.hasVoted) {
      return null;
    }
    return null;
  }

  LeaderVotingFlowKind resolveLeaderVotingFlowKindForStart() {
    if (category.isInvestment &&
        _inferClosureVoteType() == ClosureVoteType.stopContributionsVote) {
      return LeaderVotingFlowKind.stopContributions;
    }
    return LeaderVotingFlowKind.markProjectSuccessful;
  }

  ProjectDetailEntity _copy({
    bool? hasActiveSuccessVote,
    ActiveClosureVoteEntity? activeClosureVote,
  }) {
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
      hasActiveSuccessVote: hasActiveSuccessVote ?? this.hasActiveSuccessVote,
      activeClosureVote: activeClosureVote ?? this.activeClosureVote,
      invites: invites,
      hasCoLeader: hasCoLeader,
      membersPagination: membersPagination,
      invitesPagination: invitesPagination,
      announcementsPagination: announcementsPagination,
    );
  }
}
