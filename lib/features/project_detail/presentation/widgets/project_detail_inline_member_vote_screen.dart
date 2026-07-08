import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_inline_member_vote_flow.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_shell.dart';

/// Full-height cast / post-vote UI while a member closure vote is open.
///
/// Replaces nesting under project-detail [PostAuthHeader] so [SuccessVoteCastContent]
/// gets the same layout as [SuccessVoteCastScreen] (pinned footer, flow header).
class ProjectDetailInlineMemberVoteScreen extends StatelessWidget {
  final ProjectDetailEntity project;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;

  const ProjectDetailInlineMemberVoteScreen({
    super.key,
    required this.project,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessVoteCastShell(
      title: project.name,
      onBack: onBack,
      child: ProjectDetailInlineMemberVoteFlow(
        project: project,
        onRefresh: onRefresh,
      ),
    );
  }
}
