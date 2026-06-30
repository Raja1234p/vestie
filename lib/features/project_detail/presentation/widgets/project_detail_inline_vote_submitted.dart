import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_member_vote_extensions.dart';
import 'package:vestie/features/project_detail/presentation/mappers/project_detail_voting_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_cast_content.dart';

/// Figma post-vote screen for members / co-leaders after they cast a closure vote.
class ProjectDetailInlineVoteSubmitted extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectDetailInlineVoteSubmitted({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessVoteCastContent(
      key: ValueKey(
        '${project.id}_'
        '${project.memberSubmittedVoteChoice.name}_'
        '${project.voting?.agreedCount}_'
        '${project.voting?.hasVoted}',
      ),
      data: successVoteCastUiDataFromProjectDetail(project),
      choice: project.memberSubmittedVoteChoice,
      canVote: false,
    );
  }
}
