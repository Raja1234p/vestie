import 'package:vestie/features/project_detail/domain/entities/closure_vote_entities.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_closure_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import 'success_vote_cast_route_args.dart';

/// Display model for the cast-vote screen (member / co-leader).
class SuccessVoteCastUiData {
  final String? projectId;
  final ProjectCategory projectCategory;
  final bool isCoLeader;
  final double goalAmount;
  final int memberCount;
  final double totalRaised;
  final String deadlineLabel;
  final int daysRemaining;
  final int thumbsUp;
  final int thumbsDown;
  final int notVoted;
  final List<ProjectVotingMemberVoteEntity> memberVotes;
  /// Investment phase 1 (stop contributions) vs phase 2 (mark successful).
  final bool isInvestmentStopContributionsVote;
  final bool isInvestmentMarkSuccessfulVote;

  const SuccessVoteCastUiData({
    this.projectId,
    required this.projectCategory,
    this.isCoLeader = false,
    required this.goalAmount,
    required this.memberCount,
    required this.totalRaised,
    required this.deadlineLabel,
    required this.daysRemaining,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notVoted,
    this.memberVotes = const [],
    this.isInvestmentStopContributionsVote = false,
    this.isInvestmentMarkSuccessfulVote = false,
  });

  factory SuccessVoteCastUiData.fromProject(ProjectDetailEntity project) {
    return SuccessVoteCastUiData(
      projectId: project.id,
      projectCategory: project.category,
      isCoLeader: project.isCoLeader,
      goalAmount: project.goalAmount,
      memberCount: project.members.length,
      totalRaised: project.currentAmount,
      deadlineLabel: 'May 12, 2025',
      daysRemaining: 21,
      thumbsUp: 4,
      thumbsDown: 2,
      notVoted: 5,
      isInvestmentStopContributionsVote:
          project.category.isInvestment && project.isStopContributionsClosureVote,
      isInvestmentMarkSuccessfulVote:
          project.category.isInvestment && project.isInvestmentMarkSuccessfulClosureVote,
    );
  }

  factory SuccessVoteCastUiData.fromArgs(SuccessVoteCastRouteArgs args) {
    return SuccessVoteCastUiData(
      projectId: args.projectId,
      projectCategory: args.projectCategory,
      isCoLeader: args.isCoLeader,
      goalAmount: args.goalAmount,
      memberCount: args.memberCount,
      totalRaised: args.totalRaised,
      deadlineLabel: args.deadlineLabel,
      daysRemaining: args.daysRemaining,
      thumbsUp: args.thumbsUp ?? 4,
      thumbsDown: args.thumbsDown ?? 2,
      notVoted: args.notYetVoted ?? 5,
      isInvestmentStopContributionsVote: args.isInvestmentStopContributionsVote,
      isInvestmentMarkSuccessfulVote: args.isInvestmentMarkSuccessfulVote,
    );
  }

  factory SuccessVoteCastUiData.fromActiveVote({
    required ActiveClosureVoteEntity vote,
    required SuccessVoteCastRouteArgs args,
  }) {
    return SuccessVoteCastUiData(
      projectId: args.projectId,
      projectCategory: args.projectCategory,
      isCoLeader: args.isCoLeader,
      goalAmount: vote.goalAmount > 0 ? vote.goalAmount : args.goalAmount,
      memberCount: vote.memberCount > 0 ? vote.memberCount : args.memberCount,
      totalRaised: vote.totalRaised > 0 ? vote.totalRaised : args.totalRaised,
      deadlineLabel: formatClosureVoteDeadlineLabel(vote.votingDeadlineUtc),
      daysRemaining: vote.daysRemaining,
      thumbsUp: vote.thumbsUp,
      thumbsDown: vote.thumbsDown,
      notVoted: vote.notYetVoted,
      isInvestmentStopContributionsVote:
          args.projectCategory == ProjectCategory.investment &&
          vote.voteType == ClosureVoteType.stopContributionsVote,
      isInvestmentMarkSuccessfulVote:
          args.projectCategory == ProjectCategory.investment &&
          vote.voteType == ClosureVoteType.finalClosureVote,
    );
  }

  SuccessVoteCastUiData copyWithTallies({
    required int thumbsUp,
    required int thumbsDown,
    required int notVoted,
  }) {
    return SuccessVoteCastUiData(
      projectId: projectId,
      projectCategory: projectCategory,
      isCoLeader: isCoLeader,
      goalAmount: goalAmount,
      memberCount: memberCount,
      totalRaised: totalRaised,
      deadlineLabel: deadlineLabel,
      daysRemaining: daysRemaining,
      thumbsUp: thumbsUp,
      thumbsDown: thumbsDown,
      notVoted: notVoted,
      memberVotes: memberVotes,
      isInvestmentStopContributionsVote: isInvestmentStopContributionsVote,
      isInvestmentMarkSuccessfulVote: isInvestmentMarkSuccessfulVote,
    );
  }
}

/// @deprecated Use [SuccessVoteCastUiData].
typedef MemberSuccessVoteUiData = SuccessVoteCastUiData;
