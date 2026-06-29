import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'project_detail_voting_card.dart';

/// Voting card block for project detail scroll bodies.
///
/// Renders nothing when the API has no Week 11 envelope or voting has not started.
class ProjectDetailVotingSections extends StatelessWidget {
  final ProjectDetailEntity project;
  final Future<void> Function() onRefresh;

  const ProjectDetailVotingSections({
    super.key,
    required this.project,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (!project.showsProjectDetailVotingCard) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectDetailVotingCard(
          key: ValueKey(
            '${project.id}_${project.votingStatus.name}_'
            '${project.voting?.hasVoted ?? false}_'
            '${project.voting?.isFinalized ?? false}',
          ),
          project: project,
          onRefresh: onRefresh,
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
