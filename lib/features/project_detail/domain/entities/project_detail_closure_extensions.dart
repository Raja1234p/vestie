import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import 'member_entity.dart';

import 'closure_vote_entities.dart';
import 'leader_voting_flow_kind.dart';
import 'project_detail_entity.dart';
import 'project_detail_member_vote_extensions.dart';
import 'project_detail_voting_entities.dart';

extension ProjectDetailEntityClosureVote on ProjectDetailEntity {
  /// Investment stop-contributions vote (phase 1), not final closure / success vote.
  bool get isStopContributionsClosureVote {
    if (!category.isInvestment) return false;
    if (apiCanStopContributions == false) return false;
    final voteType = activeClosureVote?.voteType;
    if (voteType == ClosureVoteType.stopContributionsVote) return true;
    if (voteType == ClosureVoteType.finalClosureVote ||
        voteType == ClosureVoteType.successVote) {
      return false;
    }
    if (votingIsInProgress) return true;
    return false;
  }

  /// Group leader — monitor stop-contributions vote from project detail wallet row.
  bool get showsViewContributionSuccessVoteAction =>
      isDetailLeader &&
      hasActiveSuccessVote &&
      isStopContributionsClosureVote &&
      (votingIsInProgress || activeClosureVote?.isOpen == true);

  /// Group leader — monitor mark-successful / vacation / emergency closure vote.
  bool get showsLeaderViewSuccessVotesAction =>
      isDetailLeader &&
      hasActiveSuccessVote &&
      !isStopContributionsClosureVote &&
      (votingIsInProgress || activeClosureVote?.isOpen == true);

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
      memberCount: _syntheticClosureVoteMemberCount(summary),
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
      if (apiCanStopContributions == false) {
        return ClosureVoteType.finalClosureVote;
      }
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
    return closureCallerVoteFromVotingSummary(project: this, summary: summary);
  }

  int _syntheticClosureVoteMemberCount(ProjectVotingSummaryEntity summary) {
    if (summary.memberVotes.isNotEmpty) return summary.memberVotes.length;
    if (summary.totalVotes > 0) return summary.totalVotes;
    final eligible = members
        .where((member) => member.role != MemberRole.leader)
        .length;
    return eligible > 0 ? eligible : 1;
  }

  /// Merges Week 11 voting fields from a fresh `GET /projects/{id}` snapshot
  /// while keeping pot / borrow / pending merges on the current entity.
  ProjectDetailEntity withVotingDetailSnapshot(ProjectDetailEntity snapshot) {
    if (id != snapshot.id) return this;
    return _copy(
      status: snapshot.status,
      projectBannerStatus: snapshot.projectBannerStatus,
      votingStatus: snapshot.votingStatus,
      detailUserRole: snapshot.detailUserRole,
      voting: snapshot.voting,
      hasWeek11ProjectDetailEnvelope:
          snapshot.hasWeek11ProjectDetailEnvelope ||
          hasWeek11ProjectDetailEnvelope,
      apiCanStopContributions: snapshot.apiCanStopContributions,
      hasActiveSuccessVote: snapshot.votingIsInProgress,
      clearActiveClosureVote: true,
    ).withSyntheticClosureVoteFromDetailVoting();
  }

  LeaderVotingFlowKind resolveLeaderVotingFlowKindForStart() {
    if (category.isInvestment &&
        _inferClosureVoteType() == ClosureVoteType.stopContributionsVote) {
      return LeaderVotingFlowKind.stopContributions;
    }
    return LeaderVotingFlowKind.markProjectSuccessful;
  }

  ProjectDetailEntity _copy({
    ProjectStatus? status,
    ProjectDetailBannerStatus? projectBannerStatus,
    ProjectVotingStatus? votingStatus,
    ProjectDetailUserRole? detailUserRole,
    ProjectVotingSummaryEntity? voting,
    bool? hasWeek11ProjectDetailEnvelope,
    bool? apiCanStopContributions,
    bool? hasActiveSuccessVote,
    ActiveClosureVoteEntity? activeClosureVote,
    bool clearActiveClosureVote = false,
  }) {
    return ProjectDetailEntity(
      id: id,
      name: name,
      category: category,
      status: status ?? this.status,
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
      projectBannerStatus: projectBannerStatus ?? this.projectBannerStatus,
      votingStatus: votingStatus ?? this.votingStatus,
      detailUserRole: detailUserRole ?? this.detailUserRole,
      voting: voting ?? this.voting,
      hasWeek11ProjectDetailEnvelope:
          hasWeek11ProjectDetailEnvelope ?? this.hasWeek11ProjectDetailEnvelope,
      apiCanStopContributions:
          apiCanStopContributions ?? this.apiCanStopContributions,
      borrowingEnabled: borrowingEnabled,
      pendingJoinRequestCount: pendingJoinRequestCount,
      projectInviteCode: projectInviteCode,
      roiPercentage: roiPercentage,
      joinApprovalRequired: joinApprovalRequired,
      minimumContributionAmount: minimumContributionAmount,
      penaltyPercentage: penaltyPercentage,
      successVoteWindowHours: successVoteWindowHours,
      hasActiveSuccessVote: hasActiveSuccessVote ?? this.hasActiveSuccessVote,
      activeClosureVote: clearActiveClosureVote
          ? null
          : (activeClosureVote ?? this.activeClosureVote),
      invites: invites,
      hasCoLeader: hasCoLeader,
      membersPagination: membersPagination,
      invitesPagination: invitesPagination,
      announcementsPagination: announcementsPagination,
    );
  }
}
