import 'package:flutter/material.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';

import 'project_detail_preview_link.dart';

/// Dev preview links for success-vote flows (member: all categories; leader: vacation/emergency).
///
/// [onPreviewSuccessVoteInPlace] — member: embedded vote UI.
/// [onPreviewViewSuccessVotesScenario] — leader: hide Contribute/Borrow, show
/// [AppStrings.btnViewSuccessVotes] on detail (does not open voting screen).
class ProjectDetailSuccessVoteDevPreviews extends StatelessWidget {
  final ProjectDetailEntity project;
  final VoidCallback? onPreviewSuccessVoteInPlace;
  final VoidCallback? onPreviewViewSuccessVotesScenario;

  const ProjectDetailSuccessVoteDevPreviews({
    super.key,
    required this.project,
    this.onPreviewSuccessVoteInPlace,
    this.onPreviewViewSuccessVotesScenario,
  });

  bool get _shows => onPreviewSuccessVoteInPlace != null
      ? project.showsMemberSuccessVoteDevPreviews
      : project.showsSuccessVoteDevPreviews;

  @override
  Widget build(BuildContext context) {
    if (!_shows) return const SizedBox.shrink();

    final firstLabel = onPreviewSuccessVoteInPlace != null
        ? AppStrings.btnPreviewSuccessVote
        : AppStrings.btnPreviewViewSuccessVotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectDetailPreviewLink(
          label: firstLabel,
          onPressed: () {
            if (onPreviewSuccessVoteInPlace != null) {
              onPreviewSuccessVoteInPlace!();
            } else if (onPreviewViewSuccessVotesScenario != null) {
              onPreviewViewSuccessVotesScenario!();
            }
          },
        ),
        ProjectDetailPreviewLink(
          label: AppStrings.btnPreviewVoteOutcomeApproved,
          onPressed: () =>
              ProjectDetailNavigation.openMemberVoteOutcomePreview(
            context,
            project: project,
            approved: true,
          ),
        ),
        ProjectDetailPreviewLink(
          label: AppStrings.btnPreviewVoteOutcomeRejected,
          onPressed: () =>
              ProjectDetailNavigation.openMemberVoteOutcomePreview(
            context,
            project: project,
            approved: false,
          ),
        ),
      ],
    );
  }
}
