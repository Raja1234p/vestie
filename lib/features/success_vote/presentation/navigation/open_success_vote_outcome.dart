import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_load_route_args.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Opens outcome UI using list-card fields only (mock flows / tests).
void openSuccessVoteOutcomeFromProject(
  BuildContext context,
  Project project,
) {
  context.push(
    AppRoutes.userVoteOutcome,
    extra: successVoteOutcomeRouteArgsFromProject(project),
  );
}

/// Home / profile completed list — load detail, then full-screen outcome UI.
void openSuccessVoteOutcomeForCompletedListProject(
  BuildContext context,
  Project project,
) {
  context.push(
    AppRoutes.userVoteOutcome,
    extra: SuccessVoteOutcomeLoadRouteArgs(
      projectId: project.id,
      initialProjectName: project.name,
    ),
  );
}
