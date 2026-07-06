import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_completed_vote_outcome_content.dart';

/// Profile → Completed Projects detail body.
///
/// Members block matches vacation / emergency leader detail during an open vote
/// (preview list only — no borrow-requests tab).
class ProfileCompletedProjectDetailContent extends StatelessWidget {
  const ProfileCompletedProjectDetailContent({
    super.key,
    required this.project,
    this.onSendVffRequest,
    this.sendingVffUserId,
  });

  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;

  @override
  Widget build(BuildContext context) {
    return ProjectDetailCompletedVoteOutcomeContent(
      project: project,
      onSendVffRequest: onSendVffRequest,
      sendingVffUserId: sendingVffUserId,
      membersOnlyLayout: true,
    );
  }
}
