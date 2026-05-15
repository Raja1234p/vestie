import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import '../../domain/entities/project_detail_route_args.dart';

/// Opens project detail for any viewer role. UI is driven by
/// `GET /projects/{id}` → `viewerMembership.role` (Leader / CoLeader / Member).
void openProjectFromCard(BuildContext context, Project p) {
  if (p.relation == ProjectRelation.joined && p.userFlow != null) {
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
            projectId: p.id,
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

  final route = p.category.isInvestment
      ? AppRoutes.investmentProjectDetail
      : AppRoutes.projectDetail;
  context.push(route, extra: ProjectDetailRouteArgs(projectId: p.id));
}
