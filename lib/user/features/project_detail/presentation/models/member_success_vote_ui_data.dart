import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';

/// Display model for member success-vote UI on project detail (preview / API-ready).
class MemberSuccessVoteUiData {
  final String? projectId;
  final double goalAmount;
  final int memberCount;
  final double totalRaised;
  final String deadlineLabel;
  final int daysRemaining;
  final int thumbsUp;
  final int thumbsDown;
  final int notVoted;

  const MemberSuccessVoteUiData({
    this.projectId,
    required this.goalAmount,
    required this.memberCount,
    required this.totalRaised,
    required this.deadlineLabel,
    required this.daysRemaining,
    required this.thumbsUp,
    required this.thumbsDown,
    required this.notVoted,
  });

  factory MemberSuccessVoteUiData.fromProject(ProjectDetailEntity project) {
    return MemberSuccessVoteUiData(
      projectId: project.id,
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

  factory MemberSuccessVoteUiData.fromArgs(UserSuccessVoteArgs args) {
    return MemberSuccessVoteUiData(
      projectId: args.projectId,
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

/// Member’s own vote on the success ballot.
enum MemberSuccessVoteChoice {
  pending,
  agreed,
  disagreed,
}
