import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Route args for [SuccessVoteCastScreen] — member / co-leader give-vote UI.
class SuccessVoteCastRouteArgs {
  final String? projectId;
  final String projectName;
  final ProjectCategory projectCategory;
  final bool isCoLeader;
  final double goalAmount;
  final int memberCount;
  final double totalRaised;
  final String deadlineLabel;
  final int daysRemaining;

  const SuccessVoteCastRouteArgs({
    this.projectId,
    required this.projectName,
    required this.projectCategory,
    this.isCoLeader = false,
    required this.goalAmount,
    required this.memberCount,
    required this.totalRaised,
    required this.deadlineLabel,
    required this.daysRemaining,
  });
}

/// @deprecated Use [SuccessVoteCastRouteArgs].
typedef UserSuccessVoteArgs = SuccessVoteCastRouteArgs;
