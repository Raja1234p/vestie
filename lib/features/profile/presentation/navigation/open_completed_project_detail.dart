import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_ui_data.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Profile → Completed Projects **View** → vote outcome, then **View Details** → detail.
void openCompletedProjectDetail(BuildContext context, Project project) {
  if (project.userFlow != null) {
    openProjectFromCard(context, project);
    return;
  }

  context.push(
    AppRoutes.userVoteOutcome,
    extra: SuccessVoteOutcomeRouteArgs(
      data: SuccessVoteOutcomeUiData.fromProject(
        project,
        isApproved: project.isSuccessVoteApproved,
      ),
      viewerRole: SuccessVoteOutcomeRole.member,
      projectCategory: project.category,
      completedProjectDetailId: project.id,
      completedProjectName: project.name,
    ),
  );
}
