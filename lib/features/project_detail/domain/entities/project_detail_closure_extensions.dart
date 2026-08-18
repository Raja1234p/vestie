import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/projects/domain/entities/project_image_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import 'member_entity.dart';

import 'closure_vote_entities.dart';
import 'continue_contributions_policy.dart';
import 'leader_voting_flow_kind.dart';
import 'project_detail_entity.dart';
import 'project_detail_member_vote_extensions.dart';
import 'project_detail_voting_entities.dart';

extension ProjectDetailEntityClosureVote on ProjectDetailEntity {
  /// Investment mark-successful / ROI confirmation vote (phase 2, funded project).
  bool get isInvestmentMarkSuccessfulClosureVote {
    if (!category.isInvestment) return false;
    if (isStopContributionsClosureVote) return false;
    final voteType = activeClosureVote?.voteType;
    if (voteType == ClosureVoteType.finalClosureVote) return true;
    if (investmentFundedPhase && votingIsInProgress) return true;
    return false;
  }

  /// Investment stop-contributions vote (phase 1), not final closure / success vote.
  bool get isStopContributionsClosureVote {
    if (!category.isInvestment) return false;
    if (voting?.voteType == ClosureVoteType.stopContributionsVote) return true;
    final voteType = activeClosureVote?.voteType;
    if (voteType == ClosureVoteType.stopContributionsVote) return true;
    if (voteType == ClosureVoteType.finalClosureVote ||
        voteType == ClosureVoteType.successVote) {
      return false;
    }
    if (investmentFundedPhase) return false;
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

  /// Continue contribution / cancel open vote — **GroupLeader only**, never
  /// members or co-leaders. Hidden at 50% of [totalJoinedMember] votes cast.
  bool get showsContinueContributionsAction {
    if (!isGroupLeader) return false;
    final summary = voting;
    if (votingStatus == ProjectVotingStatus.pending &&
        summary != null &&
        !summary.isFinalized) {
      return groupLeaderCanContinueContributions(
        isGroupLeader: true,
        voteWindowOpen: true,
        totalJoinedMember: totalJoinedMember,
        votesCast: summary.agreedCount + summary.disagreedCount,
        apiCanContinueContributions: summary.canContinueContributions,
      );
    }
    final vote = activeClosureVote;
    if (vote != null && vote.isOpen && summary == null) {
      return groupLeaderCanContinueContributions(
        isGroupLeader: true,
        voteWindowOpen: true,
        totalJoinedMember: totalJoinedMember,
        votesCast: vote.thumbsUp + vote.thumbsDown,
        apiCanContinueContributions: null,
      );
    }
    return false;
  }

  String get continueContributionsButtonLabel {
    if (isInvestmentMarkSuccessfulClosureVote) {
      return AppStrings.btnCancelVote;
    }
    return AppStrings.btnContinueContribution;
  }

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
      totalRaised: isInvestmentMarkSuccessfulClosureVote &&
              totalDistributedWithRoi > 0
          ? totalDistributedWithRoi
          : currentAmount,
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
    final fromApi = voting?.voteType;
    if (fromApi != null) return fromApi;
    if (category.isInvestment) {
      if (investmentFundedPhase) {
        return ClosureVoteType.finalClosureVote;
      }
      if (votingIsInProgress) {
        return ClosureVoteType.stopContributionsVote;
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
      displayStatusLabel: snapshot.displayStatusLabel,
      projectLifecycleState: snapshot.projectLifecycleState,
      viewerRefundAmount: snapshot.viewerRefundAmount,
      totalDistributedWithRoi: snapshot.totalDistributedWithRoi,
      votingStatus: snapshot.votingStatus,
      detailUserRole: snapshot.detailUserRole,
      voting: snapshot.voting,
      hasWeek11ProjectDetailEnvelope:
          snapshot.hasWeek11ProjectDetailEnvelope ||
          hasWeek11ProjectDetailEnvelope,
      apiCanStopContributions: snapshot.apiCanStopContributions,
      hasActiveSuccessVote: snapshot.votingIsInProgress,
      coverImageUrl: snapshot.coverImageUrl,
      images: snapshot.images,
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
    String? displayStatusLabel,
    String? projectLifecycleState,
    double? viewerRefundAmount,
    double? totalDistributedWithRoi,
    ProjectVotingStatus? votingStatus,
    ProjectDetailUserRole? detailUserRole,
    ProjectVotingSummaryEntity? voting,
    bool? hasWeek11ProjectDetailEnvelope,
    bool? apiCanStopContributions,
    bool? hasActiveSuccessVote,
    ActiveClosureVoteEntity? activeClosureVote,
    String? coverImageUrl,
    List<ProjectImageEntity>? images,
    bool clearActiveClosureVote = false,
  }) {
    return ProjectDetailEntity(
      id: id,
      name: name,
      category: category,
      status: status ?? this.status,
      goalAmount: goalAmount,
      currentAmount: currentAmount,
      totalContributed: totalContributed,
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
      displayStatusLabel: displayStatusLabel ?? this.displayStatusLabel,
      projectLifecycleState: projectLifecycleState ?? this.projectLifecycleState,
      viewerRefundAmount: viewerRefundAmount ?? this.viewerRefundAmount,
      totalDistributedWithRoi:
          totalDistributedWithRoi ?? this.totalDistributedWithRoi,
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
      totalJoinedMember: totalJoinedMember,
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
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      images: images ?? this.images,
      membersPagination: membersPagination,
      invitesPagination: invitesPagination,
      announcementsPagination: announcementsPagination,
    );
  }
}
