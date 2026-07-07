import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/success_vote/presentation/navigation/open_success_vote_outcome.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
/// Profile → Completed Projects **View** → vote outcome, then **View Details** → detail.
void openCompletedProjectDetail(BuildContext context, Project project) {
  if (project.userFlow != null) {
    openProjectFromCard(context, project);
    return;
  }

  openSuccessVoteOutcomeFromProject(
    context,
    project,
    completedProjectDetailId: project.id,
    completedProjectName: project.name,
  );
}
