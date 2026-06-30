import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_member_vote_extensions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_inline_cast_vote.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_inline_vote_submitted.dart';
class ProjectDetailInlineMemberVoteFlow extends StatelessWidget {
  final ProjectDetailEntity project;
  final Future<void> Function() onRefresh;

  const ProjectDetailInlineMemberVoteFlow({
    super.key,
    required this.project,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (project.showsInlineMemberVoteCastView) {
      return ProjectDetailInlineCastVote(
        project: project,
        onRefresh: onRefresh,
      );
    }

    if (project.showsInlineMemberVoteSubmittedView) {
      return ProjectDetailInlineVoteSubmitted(project: project);
    }

    return const SizedBox.shrink();
  }
}
