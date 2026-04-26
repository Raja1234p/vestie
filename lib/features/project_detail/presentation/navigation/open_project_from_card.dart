import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../home/domain/entities/project.dart' show Project, UserFlowOnOpen, ProjectCategory;
import '../../domain/entities/project_detail_route_args.dart';
import '../mocks/mock_project_detail_from_card.dart';

/// Single entry for Home / Discover when a project card is tapped. Handles
/// optional [Project.userFlow] (member test flows) without coupling cards to
/// specific screens beyond this map.
void openProjectFromCard(
  BuildContext context,
  Project p, {
  required bool isLeaderView,
}) {
  if (!isLeaderView && p.userFlow != null) {
    final name = p.name;
    switch (p.userFlow!) {
      case UserFlowOnOpen.showJoinApproved:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.joinApproved,
          ),
        );
        return;
      case UserFlowOnOpen.showJoinRejected:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.joinRejected,
          ),
        );
        return;
      case UserFlowOnOpen.showSuccessVote:
        context.push(
          AppRoutes.userSuccessVote,
          extra: UserSuccessVoteArgs(
            projectName: name,
            goalAmount: p.goalAmount ?? 5000,
            memberCount: 5,
            totalRaised: p.currentAmount ?? 4800,
            deadlineLabel: 'May 12, 2025',
            daysRemaining: 21,
          ),
        );
        return;
      case UserFlowOnOpen.showMarkVoteApprovedResult:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.markVotedSuccess,
          ),
        );
        return;
      case UserFlowOnOpen.showMarkVoteNotApprovedResult:
        context.push(
          AppRoutes.userStatusFlow,
          extra: UserStatusFlowArgs(
            projectName: name,
            kind: UserStatusFlowKind.markVotedIncomplete,
          ),
        );
        return;
    }
  }

  final detail = mockProjectDetailFromCard(p, isLeaderView: isLeaderView);
  final route = p.category == ProjectCategory.investment
      ? AppRoutes.investmentProjectDetail
      : AppRoutes.projectDetail;
  context.push(route, extra: ProjectDetailRouteArgs(project: detail));
}
