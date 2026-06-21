import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';

import 'project_detail_preview_link.dart';

/// Dev preview for member / co-leader **cast vote** (give vote) — not outcome.
class ProjectDetailCastVoteDevPreviews extends StatelessWidget {
  final ProjectDetailEntity project;
  final VoidCallback? onPreviewCastVoteInPlace;

  const ProjectDetailCastVoteDevPreviews({
    super.key,
    required this.project,
    this.onPreviewCastVoteInPlace,
  });

  bool get _shows =>
      project.showsMemberSuccessVoteDevPreviews &&
      (project.isMemberView || project.isCoLeader);

  @override
  Widget build(BuildContext context) {
    if (!_shows) return const SizedBox.shrink();

    return ProjectDetailPreviewLink(
      label: AppStrings.btnPreviewCastVote,
      onPressed: () {
        if (onPreviewCastVoteInPlace != null) {
          onPreviewCastVoteInPlace!();
        } else {
          ProjectDetailNavigation.openCastVotePreview(context, project: project);
        }
      },
    );
  }
}
