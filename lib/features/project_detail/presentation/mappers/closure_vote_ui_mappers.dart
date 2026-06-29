import 'package:intl/intl.dart';

import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_variant.dart';
import 'package:vestie/leader/features/project_detail/presentation/models/leader_success_vote_progress_ui_data.dart';

/// Formats closure vote deadline for cast / monitor screens.
String formatClosureVoteDeadlineLabel(DateTime deadlineUtc) {
  return DateFormat('MMM d, yyyy').format(deadlineUtc.toLocal());
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

  final members = memberRoster ??
      (project != null && project.members.isNotEmpty
          ? project.members
                .map((m) {
                  final name = m.name.isNotEmpty ? m.name : m.username;
                  return LeaderSuccessVoteMemberRow(
                    name: name,
                    status: LeaderMemberVoteStatus.waiting,
                  );
                })
                .toList(growable: false)
          : LeaderSuccessVoteProgressUiData.preview(project: project).members);

  return LeaderSuccessVoteProgressUiData(
    agreedCount: vote.thumbsUp,
    disagreedCount: vote.thumbsDown,
    notVotedCount: vote.notYetVoted,
    majorityRequired: majority,
    totalMembers: total,
    remaining: vote.remainingDuration,
    members: members,
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
  );
}

/// Week 10 `outcome` → approved / rejected for outcome UI.
bool isClosureVoteOutcomeApproved(ClosureVoteOutcome outcome) {
  return switch (outcome) {
    ClosureVoteOutcome.success => true,
    ClosureVoteOutcome.investmentStarted => true,
    ClosureVoteOutcome.refund => false,
    ClosureVoteOutcome.disputed => false,
  };
}

/// Maps finalize payload to the existing outcome screen variants.
SuccessVoteOutcomeVariant successVoteOutcomeVariantFromClosureVote({
  required ClosureVoteType voteType,
  required ClosureVoteOutcome outcome,
}) {
  if (voteType == ClosureVoteType.stopContributionsVote &&
      !isClosureVoteOutcomeApproved(outcome)) {
    return SuccessVoteOutcomeVariant.stopContributionsRejected;
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
    project: role.isModerator ? project : null,
    projectCategory: project.category,
  );
}
