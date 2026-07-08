import 'package:intl/intl.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_closure_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_distribution_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_refund_phase.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

/// Formats closure vote deadline for cast / monitor screens.
String formatClosureVoteDeadlineLabel(DateTime deadlineUtc) {
  return DateFormat('MMM d, yyyy').format(deadlineUtc.toLocal());
}

LeaderMemberVoteStatus leaderMemberVoteStatusFromProjectVote(
  ProjectMemberVoteStatus status,
) {
  return switch (status) {
    ProjectMemberVoteStatus.agreed => LeaderMemberVoteStatus.agreed,
    ProjectMemberVoteStatus.disagreed => LeaderMemberVoteStatus.disagreed,
    ProjectMemberVoteStatus.waiting => LeaderMemberVoteStatus.waiting,
  };
}

List<LeaderSuccessVoteMemberRow> leaderMemberVoteRowsFromProjectVoting({
  required List<ProjectVotingMemberVoteEntity> memberVotes,
  List<MemberEntity> projectMembers = const [],
}) {
  if (memberVotes.isEmpty) return const [];

  final membersById = <String, MemberEntity>{
    for (final member in projectMembers)
      if (member.membershipId.isNotEmpty) member.membershipId: member,
  };
  final membersByUserId = <String, MemberEntity>{
    for (final member in projectMembers)
      if (member.userId.isNotEmpty) member.userId: member,
  };

  return memberVotes
      .map((vote) {
        final matched = membersById[vote.membershipId] ??
            membersByUserId[vote.userId];
        final name = vote.displayName.isNotEmpty
            ? vote.displayName
            : matched != null
            ? (matched.name.isNotEmpty ? matched.name : matched.username)
            : '';
        return LeaderSuccessVoteMemberRow(
          name: name.isNotEmpty ? name : AppStrings.tabMember,
          status: leaderMemberVoteStatusFromProjectVote(vote.status),
        );
      })
      .toList(growable: false);
}

List<LeaderSuccessVoteMemberRow> _leaderMemberVoteRowsForProject(
  ProjectDetailEntity? project,
) {
  final memberVotes = project?.voting?.memberVotes ?? const [];
  if (memberVotes.isNotEmpty) {
    return leaderMemberVoteRowsFromProjectVoting(
      memberVotes: memberVotes,
      projectMembers: project?.members ?? const [],
    );
  }

  final eligibleMembers = _eligibleClosureVoteMembers(project?.members ?? const []);
  if (eligibleMembers.isNotEmpty) {
    return eligibleMembers
        .map((m) {
          final name = m.name.isNotEmpty ? m.name : m.username;
          return LeaderSuccessVoteMemberRow(
            name: name,
            status: LeaderMemberVoteStatus.waiting,
          );
        })
        .toList(growable: false);
  }

  return const [];
}

/// Eligible voter count for tallies / summary cards from Week 11 detail.
int closureVoteEligibleMemberCountFromProject(ProjectDetailEntity project) {
  final voting = project.voting;
  return _closureVoteEligibleMemberCount(
    project: project,
    talliedTotal: voting?.totalVotes ?? 0,
    memberVotes: voting?.memberVotes ?? const [],
  );
}

List<MemberEntity> _eligibleClosureVoteMembers(List<MemberEntity> members) {
  return members
      .where((member) => member.role != MemberRole.leader)
      .toList(growable: false);
}

int _closureVoteEligibleMemberCount({
  required ProjectDetailEntity? project,
  required int talliedTotal,
  required List<ProjectVotingMemberVoteEntity> memberVotes,
}) {
  final eligibleFromApi = project?.voting?.eligibleVoterCount;
  if (eligibleFromApi != null && eligibleFromApi > 0) return eligibleFromApi;
  if (memberVotes.isNotEmpty) return memberVotes.length;
  if (talliedTotal > 0) return talliedTotal;
  final eligible = _eligibleClosureVoteMembers(project?.members ?? const []);
  if (eligible.isNotEmpty) return eligible.length;
  return project != null && project.members.isNotEmpty ? project.members.length : 1;
}

bool _isStopContributionsMonitorVote({
  required ProjectDetailEntity? project,
  ActiveClosureVoteEntity? vote,
}) {
  if (vote?.voteType == ClosureVoteType.stopContributionsVote) return true;
  return project?.isStopContributionsClosureVote ?? false;
}

/// Week 11+ leader monitor from `GET /projects/{id}` → `voting` only.
LeaderSuccessVoteProgressUiData leaderSuccessVoteProgressFromProjectVoting({
  required ProjectDetailEntity project,
  required ProjectVotingSummaryEntity voting,
}) {
  final total = _closureVoteEligibleMemberCount(
    project: project,
    talliedTotal: voting.totalVotes,
    memberVotes: voting.memberVotes,
  );
  final majority = total <= 1 ? 1 : (total / 2).floor() + 1;
  final remaining = voting.deadlineAtUtc.difference(DateTime.now().toUtc());
  final clampedRemaining = remaining.isNegative ? Duration.zero : remaining;

  return LeaderSuccessVoteProgressUiData(
    agreedCount: voting.agreedCount,
    disagreedCount: voting.disagreedCount,
    notVotedCount: voting.pendingCount,
    majorityRequired: majority,
    totalMembers: total,
    remaining: clampedRemaining,
    members: _leaderMemberVoteRowsForProject(project),
    isStopContributionsVote: _isStopContributionsMonitorVote(project: project),
  );
}

LeaderSuccessVoteProgressUiData leaderSuccessVoteProgressFromActiveVote({
  required ActiveClosureVoteEntity vote,
  ProjectDetailEntity? project,
  List<LeaderSuccessVoteMemberRow>? memberRoster,
}) {
  final total = vote.memberCount > 0
      ? vote.memberCount
      : (project != null && project.members.isNotEmpty
            ? project.members.length
            : memberRoster != null && memberRoster.isNotEmpty
            ? memberRoster.length
            : 1);
  final majority = total <= 1 ? 1 : (total / 2).floor() + 1;

  final members = memberRoster ?? _leaderMemberVoteRowsForProject(project);

  return LeaderSuccessVoteProgressUiData(
    agreedCount: vote.thumbsUp,
    disagreedCount: vote.thumbsDown,
    notVotedCount: vote.notYetVoted,
    majorityRequired: majority,
    totalMembers: total,
    remaining: vote.remainingDuration,
    members: members,
    isStopContributionsVote: _isStopContributionsMonitorVote(
      project: project,
      vote: vote,
    ),
  );
}

SuccessVoteCastRouteArgs successVoteCastRouteArgsFromProject(
  ProjectDetailEntity project,
) {
  final vote = project.activeClosureVote;
  return SuccessVoteCastRouteArgs(
    projectId: project.id,
    projectName: project.name,
    projectCategory: project.category,
    isCoLeader: project.isCoLeader,
    goalAmount: vote != null && vote.goalAmount > 0
        ? vote.goalAmount
        : project.goalAmount,
    memberCount: vote != null && vote.memberCount > 0
        ? vote.memberCount
        : project.members.length,
    totalRaised: vote != null && vote.totalRaised > 0
        ? vote.totalRaised
        : project.currentAmount,
    deadlineLabel: vote != null
        ? formatClosureVoteDeadlineLabel(vote.votingDeadlineUtc)
        : project.endsIn,
    daysRemaining: vote?.daysRemaining ?? 0,
    thumbsUp: vote?.thumbsUp,
    thumbsDown: vote?.thumbsDown,
    notYetVoted: vote?.notYetVoted,
    isInvestmentStopContributionsVote: project.isStopContributionsClosureVote,
    isInvestmentMarkSuccessfulVote: project.isInvestmentMarkSuccessfulClosureVote,
  );
}

/// Maps finalize / detail payload to the existing outcome screen variants.
SuccessVoteOutcomeVariant successVoteOutcomeVariantFromClosureVote({
  required ClosureVoteType voteType,
  required ClosureVoteOutcome outcome,
}) {
  if (voteType == ClosureVoteType.stopContributionsVote) {
    if (outcome == ClosureVoteOutcome.refund) {
      return SuccessVoteOutcomeVariant.successVote;
    }
    if (!isClosureVoteOutcomeApproved(outcome)) {
      return SuccessVoteOutcomeVariant.stopContributionsRejected;
    }
  }
  return SuccessVoteOutcomeVariant.successVote;
}

SuccessVoteOutcomeUiData successVoteOutcomeUiDataFromFinalize({
  required FinalizeClosureVoteResultEntity result,
  required double amountUsd,
  int? totalMemberCount,
}) {
  final talliedTotal =
      result.thumbsUp + result.thumbsDown + result.notYetVoted;
  final total = totalMemberCount ?? (talliedTotal > 0 ? talliedTotal : 1);

  return SuccessVoteOutcomeUiData(
    isApproved: isClosureVoteOutcomeApproved(result.outcome),
    amountUsd: amountUsd,
    agreedCount: result.thumbsUp,
    disagreedCount: result.thumbsDown,
    totalMemberCount: total,
  );
}

SuccessVoteOutcomeRouteArgs successVoteOutcomeRouteArgsFromFinalize({
  required ProjectDetailEntity project,
  required FinalizeClosureVoteResultEntity result,
}) {
  final role = SuccessVoteOutcomeRole.fromViewerRole(project.viewerRole);

  return SuccessVoteOutcomeRouteArgs(
    data: successVoteOutcomeUiDataFromFinalize(
      result: result,
      amountUsd: project.currentAmount,
      totalMemberCount: project.members.isNotEmpty
          ? project.members.length
          : null,
    ),
    viewerRole: role,
    variant: successVoteOutcomeVariantFromClosureVote(
      voteType: result.voteType,
      outcome: result.outcome,
    ),
    refundPhase: refundPhaseFromProjectDetail(project),
    distributionPhase: distributionPhaseFromProjectDetail(project),
    project: role.isModerator ? project : null,
    projectCategory: project.category,
  );
}

/// Completed project detail — approved / rejected / refund outcome block.
SuccessVoteOutcomeUiData successVoteOutcomeUiDataFromProjectDetail(
  ProjectDetailEntity project,
) {
  final voting = project.voting;
  final eligibleTotal = closureVoteEligibleMemberCountFromProject(project);

  if (voting != null && project.hasCompletedVoteTallies) {
    final tallied =
        voting.agreedCount + voting.disagreedCount + voting.pendingCount;
    final total = tallied > 0 ? tallied : eligibleTotal;
    return SuccessVoteOutcomeUiData(
      isApproved: project.isClosureVoteOutcomeApproved,
      amountUsd: project.currentAmount,
      agreedCount: voting.agreedCount,
      disagreedCount: voting.disagreedCount,
      totalMemberCount: total > 0 ? total : 1,
    );
  }

  final total = eligibleTotal > 0 ? eligibleTotal : 1;
  final approved = project.isClosureVoteOutcomeApproved;
  final majority = total <= 1 ? 1 : (total / 2).floor() + 1;
  return SuccessVoteOutcomeUiData(
    isApproved: approved,
    amountUsd: project.currentAmount,
    agreedCount: approved ? majority : total - majority,
    disagreedCount: approved ? total - majority : majority,
    totalMemberCount: total,
  );
}

SuccessVoteOutcomeVariant completedOutcomeVariantFromProjectDetail(
  ProjectDetailEntity project,
) {
  final voteType = project.voting?.voteType;
  if (voteType != null) {
    final outcome = project.voting?.outcome ??
        (project.isClosureVoteOutcomeApproved
            ? ClosureVoteOutcome.success
            : ClosureVoteOutcome.disputed);
    return successVoteOutcomeVariantFromClosureVote(
      voteType: voteType,
      outcome: outcome,
    );
  }
  if (project.category.isInvestment &&
      !project.investmentContributionsAreClosed &&
      !project.isClosureVoteOutcomeApproved) {
    return SuccessVoteOutcomeVariant.stopContributionsRejected;
  }
  return SuccessVoteOutcomeVariant.successVote;
}

SuccessVoteOutcomeVariant completedOutcomeVariantFromProject(Project project) {
  final voteTypeRaw = project.lastVoteType;
  if (voteTypeRaw != null && voteTypeRaw.trim().isNotEmpty) {
    final voteType = parseClosureVoteType(voteTypeRaw);
    final outcomeRaw = project.lastVoteOutcome;
    final outcome = outcomeRaw != null && outcomeRaw.trim().isNotEmpty
        ? parseClosureVoteOutcome(outcomeRaw)
        : (project.isSuccessVoteApproved
            ? ClosureVoteOutcome.success
            : ClosureVoteOutcome.disputed);
    return successVoteOutcomeVariantFromClosureVote(
      voteType: voteType,
      outcome: outcome,
    );
  }
  if (project.category.isInvestment &&
      !project.investmentContributionsAreClosed &&
      !project.isSuccessVoteApproved) {
    return SuccessVoteOutcomeVariant.stopContributionsRejected;
  }
  return SuccessVoteOutcomeVariant.successVote;
}

SuccessVoteOutcomeRefundPhase refundPhaseFromProjectDetail(
  ProjectDetailEntity project,
) {
  if (!project.showsClosureVoteRefundOutcome) {
    return SuccessVoteOutcomeRefundPhase.none;
  }
  if (project.voting?.outcome == ClosureVoteOutcome.refund) {
    final phase = refundPhaseFromDisplayStatus(project.displayStatusLabel);
    return phase.isRefund ? phase : SuccessVoteOutcomeRefundPhase.inProgress;
  }
  final phase = refundPhaseFromDisplayStatus(project.displayStatusLabel);
  if (phase.isRefund) return phase;
  return SuccessVoteOutcomeRefundPhase.inProgress;
}

SuccessVoteOutcomeRefundPhase refundPhaseFromProject(Project project) {
  if (!project.category.isInvestment) {
    return SuccessVoteOutcomeRefundPhase.none;
  }
  final voteTypeRaw = project.lastVoteType;
  if (voteTypeRaw == null || voteTypeRaw.trim().isEmpty) {
    return SuccessVoteOutcomeRefundPhase.none;
  }
  final voteType = parseClosureVoteType(voteTypeRaw);
  if (voteType != ClosureVoteType.stopContributionsVote) {
    return SuccessVoteOutcomeRefundPhase.none;
  }
  final outcomeRaw = project.lastVoteOutcome;
  if (outcomeRaw != null &&
      outcomeRaw.trim().isNotEmpty &&
      parseClosureVoteOutcome(outcomeRaw) == ClosureVoteOutcome.refund) {
    final phase = refundPhaseFromDisplayStatus(project.displayStatus);
    return phase.isRefund ? phase : SuccessVoteOutcomeRefundPhase.inProgress;
  }
  final phase = refundPhaseFromDisplayStatus(project.displayStatus);
  if (phase.isRefund) return phase;
  return SuccessVoteOutcomeRefundPhase.none;
}

bool _isApprovedInvestmentFinalClosure(ProjectDetailEntity project) {
  if (!project.category.isInvestment || !project.isClosureVoteOutcomeApproved) {
    return false;
  }
  final voteType = project.voting?.voteType;
  if (voteType == ClosureVoteType.stopContributionsVote) return false;
  if (voteType == ClosureVoteType.finalClosureVote) return true;
  final outcome = project.voting?.outcome;
  if (outcome == ClosureVoteOutcome.investmentStarted) return true;
  return project.investmentContributionsAreClosed &&
      project.isClosureVoteOutcomeApproved;
}

bool _isApprovedInvestmentFinalClosureFromList(Project project) {
  if (!project.category.isInvestment || !project.isSuccessVoteApproved) {
    return false;
  }
  final voteTypeRaw = project.lastVoteType;
  if (voteTypeRaw != null &&
      parseClosureVoteType(voteTypeRaw) ==
          ClosureVoteType.stopContributionsVote) {
    return false;
  }
  if (voteTypeRaw != null &&
      parseClosureVoteType(voteTypeRaw) == ClosureVoteType.finalClosureVote) {
    return true;
  }
  final outcomeRaw = project.lastVoteOutcome;
  if (outcomeRaw != null &&
      parseClosureVoteOutcome(outcomeRaw) ==
          ClosureVoteOutcome.investmentStarted) {
    return true;
  }
  return project.investmentContributionsAreClosed;
}

SuccessVoteOutcomeDistributionPhase _resolveDistributionPhase({
  required bool isApprovedInvestmentFinalClosure,
  String? distributionStatus,
  String? displayStatus,
}) {
  if (!isApprovedInvestmentFinalClosure) {
    return SuccessVoteOutcomeDistributionPhase.none;
  }

  if (distributionStatus != null && distributionStatus.trim().isNotEmpty) {
    final fromApi = distributionPhaseFromApiValue(distributionStatus);
    if (fromApi.isDistribution) return fromApi;
  }

  return distributionPhaseFromStatusLabel(displayStatus);
}

SuccessVoteOutcomeDistributionPhase distributionPhaseFromProjectDetail(
  ProjectDetailEntity project,
) {
  return _resolveDistributionPhase(
    isApprovedInvestmentFinalClosure: _isApprovedInvestmentFinalClosure(project),
    distributionStatus: project.voting?.distributionStatus,
    displayStatus: project.displayStatusLabel,
  );
}

SuccessVoteOutcomeDistributionPhase distributionPhaseFromProject(
  Project project,
) {
  return _resolveDistributionPhase(
    isApprovedInvestmentFinalClosure:
        _isApprovedInvestmentFinalClosureFromList(project),
    distributionStatus: project.distributionStatus,
    displayStatus: project.displayStatus,
  );
}

SuccessVoteOutcomeRouteArgs successVoteOutcomeRouteArgsFromProject(
  Project project,
) {
  final role = SuccessVoteOutcomeRole.fromViewerRole(project.viewerRole);

  return SuccessVoteOutcomeRouteArgs(
    data: SuccessVoteOutcomeUiData.fromProject(
      project,
      isApproved: project.isSuccessVoteApproved,
    ),
    viewerRole: role,
    variant: completedOutcomeVariantFromProject(project),
    refundPhase: refundPhaseFromProject(project),
    distributionPhase: distributionPhaseFromProject(project),
    projectCategory: project.category,
  );
}

SuccessVoteOutcomeRouteArgs successVoteOutcomeRouteArgsFromProjectDetail(
  ProjectDetailEntity project,
) {
  final role = SuccessVoteOutcomeRole.fromViewerRole(project.viewerRole);

  return SuccessVoteOutcomeRouteArgs(
    data: successVoteOutcomeUiDataFromProjectDetail(project),
    viewerRole: role,
    variant: completedOutcomeVariantFromProjectDetail(project),
    refundPhase: refundPhaseFromProjectDetail(project),
    distributionPhase: distributionPhaseFromProjectDetail(project),
    project: role.isModerator ? project : null,
    projectCategory: project.category,
  );
}
