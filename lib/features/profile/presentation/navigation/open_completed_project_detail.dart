import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

/// Profile → Completed Projects **View** → project detail (API-driven outcome).
void openCompletedProjectDetail(BuildContext context, Project project) {
  openProjectFromCard(context, project);
}
