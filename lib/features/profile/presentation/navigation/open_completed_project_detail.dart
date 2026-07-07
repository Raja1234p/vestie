import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Profile → Completed Projects **View** → full-screen outcome UI.
void openCompletedProjectDetail(BuildContext context, Project project) {
  openCompletedProjectView(context, project);
}
