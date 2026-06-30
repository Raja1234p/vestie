import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

import 'project_detail_preview_link.dart';

/// Dev preview links for **vote outcome** screens (approved / rejected).
class ProjectDetailVoteOutcomeDevPreviews extends StatelessWidget {
  final ProjectDetailEntity project;
  final VoidCallback? onPreviewViewSuccessVotesScenario;

  /// Vacation / emergency only — investment GL skips view-success-votes preview.
  final bool includeViewSuccessVotesPreview;

  const ProjectDetailVoteOutcomeDevPreviews({
    super.key,
    required this.project,
    this.onPreviewViewSuccessVotesScenario,
    this.includeViewSuccessVotesPreview = true,
  });

  bool get _showsModerator =>
      project.showsSuccessVoteDevPreviews ||
      project.showsInvestmentVoteOutcomeDevPreviews;

  bool get _shows =>
      kDebugMode &&
      (project.showsMemberSuccessVoteDevPreviews || _showsModerator);

  bool get _showsViewSuccessVotesPreview =>
      includeViewSuccessVotesPreview &&
      onPreviewViewSuccessVotesScenario != null &&
      project.showsSuccessVoteDevPreviews;

  @override
  Widget build(BuildContext context) {
    if (!_shows) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showsViewSuccessVotesPreview)
          ProjectDetailPreviewLink(
            label: AppStrings.btnPreviewViewSuccessVotes,
            onPressed: onPreviewViewSuccessVotesScenario!,
          ),
        ProjectDetailPreviewLink(
          label: AppStrings.btnPreviewVoteOutcomeApproved,
          onPressed: () => ProjectDetailNavigation.openMemberVoteOutcomePreview(
            context,
            project: project,
            approved: true,
          ),
        ),
        ProjectDetailPreviewLink(
          label: AppStrings.btnPreviewVoteOutcomeRejected,
          onPressed: () => ProjectDetailNavigation.openMemberVoteOutcomePreview(
            context,
            project: project,
            approved: false,
          ),
        ),
        if (project.canStopContributions ||
            (project.isMemberView && project.category.isInvestment))
          ProjectDetailPreviewLink(
            label: AppStrings.btnPreviewStopContributionsVoteRejected,
            onPressed: () =>
                ProjectDetailNavigation.openStopContributionsVoteRejectedPreview(
              context,
              project: project,
            ),
          ),
      ],
    );
  }
}
