import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'project_detail_status_banner.dart';
import 'project_detail_voting_card.dart';

/// Status banner + voting card block for project detail scroll bodies.
///
/// Renders nothing when the API has no Week 11 envelope — legacy detail is unchanged.
class ProjectDetailVotingSections extends StatelessWidget {
  final ProjectDetailEntity project;
  final Future<void> Function() onRefresh;

  const ProjectDetailVotingSections({
    super.key,
    required this.project,
    required this.onRefresh,
  });

  bool get _hasContent =>
      project.showsProjectDetailStatusBanner ||
      project.showsProjectDetailVotingCard;

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (project.showsProjectDetailStatusBanner) ...[
          ProjectDetailStatusBanner(project: project),
          SizedBox(height: 12.h),
        ],
        if (project.showsProjectDetailVotingCard)
          ProjectDetailVotingCard(
            key: ValueKey(
              '${project.id}_${project.votingStatus.name}_'
              '${project.voting?.hasVoted ?? false}_'
              '${project.voting?.isFinalized ?? false}',
            ),
            project: project,
            onRefresh: onRefresh,
          ),
        if (project.showsProjectDetailVotingCard) SizedBox(height: 16.h),
      ],
    );
  }
}
