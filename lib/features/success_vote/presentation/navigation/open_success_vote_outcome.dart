import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Opens the shared success-vote outcome screen (approved / rejected) with
/// role- and category-specific copy from [Project.viewerRole].
void openSuccessVoteOutcomeFromProject(
  BuildContext context,
  Project project, {
  String? completedProjectDetailId,
  String? completedProjectName,
}) {
  context.push(
    AppRoutes.userVoteOutcome,
    extra: successVoteOutcomeRouteArgsFromProject(
      project,
      completedProjectDetailId: completedProjectDetailId,
      completedProjectName: completedProjectName,
    ),
  );
}
