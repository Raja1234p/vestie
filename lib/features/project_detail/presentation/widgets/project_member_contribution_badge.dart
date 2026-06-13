import 'package:flutter/material.dart';

import 'project_member_primary_pill_badge.dart';

/// Top Contributor pill — same primary pill + crown icon as VFF; label from API.
class ProjectMemberContributionBadge extends StatelessWidget {
  final String label;

  const ProjectMemberContributionBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return ProjectMemberPrimaryPillBadge(label: label);
  }
}
