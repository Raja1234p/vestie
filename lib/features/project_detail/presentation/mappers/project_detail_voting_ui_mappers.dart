import 'package:intl/intl.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_cast_ui_data.dart';

int closureVoteMajorityRequired(int totalMembers) {
  if (totalMembers <= 1) return 1;
  return (totalMembers / 2).floor() + 1;
}

String formatProjectVotingDateTime(DateTime utc) {
  return DateFormat('MMM d, yyyy').format(utc.toLocal());
}

int projectVotingDaysRemaining(DateTime deadlineUtc) {
  final diff = deadlineUtc.toUtc().difference(DateTime.now().toUtc());
  if (diff.isNegative) return 0;
  return diff.inDays;
}

SuccessVoteCastUiData successVoteCastUiDataFromProjectDetail(
  ProjectDetailEntity project,
) {
  final vote = project.activeClosureVote;
  final summary = project.voting;
  final deadlineUtc = summary?.deadlineAtUtc ?? vote?.votingDeadlineUtc;
  final deadlineLabel = deadlineUtc != null
      ? formatClosureVoteDeadlineLabel(deadlineUtc)
      : project.endsIn;
  final eligibleMemberCount = closureVoteEligibleMemberCountFromProject(project);

  return SuccessVoteCastUiData(
    projectId: project.id,
    projectCategory: project.category,
    isCoLeader: project.isDetailCoLeader,
    goalAmount: vote != null && vote.goalAmount > 0
        ? vote.goalAmount
        : project.goalAmount,
    memberCount: eligibleMemberCount,
    totalRaised: vote != null && vote.totalRaised > 0
        ? vote.totalRaised
        : project.currentAmount,
    deadlineLabel: deadlineLabel,
    daysRemaining: vote?.daysRemaining ??
        (deadlineUtc != null ? projectVotingDaysRemaining(deadlineUtc) : 0),
    thumbsUp: summary?.agreedCount ?? vote?.thumbsUp ?? 0,
    thumbsDown: summary?.disagreedCount ?? vote?.thumbsDown ?? 0,
    notVoted: summary?.pendingCount ?? vote?.notYetVoted ?? 0,
    memberVotes: summary?.memberVotes ?? const [],
  );
}
