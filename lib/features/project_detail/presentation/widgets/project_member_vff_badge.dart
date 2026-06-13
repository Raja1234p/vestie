import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'project_member_primary_pill_badge.dart';

/// VFF pill on project member rows — shares primary pill with Top Contributor.
class ProjectMemberVffBadge extends StatelessWidget {
  const ProjectMemberVffBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectMemberPrimaryPillBadge(
      label: AppStrings.userVffBadgeVff,
    );
  }
}
