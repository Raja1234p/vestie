import 'package:flutter/material.dart';

import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_completed_vote_outcome_content.dart';

/// Shared layout: member (or any read-only) view when the project is **completed** —
/// vote outcome (approved / rejected / refund) and members only.
///
/// Screens own navigation; this widget only composes existing building blocks.
class ProjectDetailUserCompletedContent extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity> onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;
  final Future<bool> Function(String announcementId)? onDeleteAnnouncement;
  final bool hideInvestmentActions;

  const ProjectDetailUserCompletedContent({
    super.key,
    required this.project,
    required this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
    this.onDeleteAnnouncement,
    this.hideInvestmentActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectDetailCompletedVoteOutcomeContent(
      project: project,
      onMemberTap: onMemberTap,
      onSendVffRequest: onSendVffRequest,
      sendingVffUserId: sendingVffUserId,
      onDeleteAnnouncement: onDeleteAnnouncement,
    );
  }
}
