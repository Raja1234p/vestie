import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

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
      thumbsUp: 4,
      thumbsDown: 2,
      notVoted: 5,
    );
  }
}

/// @deprecated Use [SuccessVoteCastUiData].
typedef MemberSuccessVoteUiData = SuccessVoteCastUiData;
