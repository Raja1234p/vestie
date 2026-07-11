import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

/// Members list without borrow-requests tabs — same block as vacation / emergency
/// leader detail while a closure vote is open.
class ProjectDetailMembersOnlySection extends StatelessWidget {
  const ProjectDetailMembersOnlySection({
    super.key,
    required this.project,
    this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
    this.title,
    this.watchBlocForVffState = false,
    this.fromCompletedProjectsProfileDetail = false,
  });

  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;
  final String? title;
  final bool watchBlocForVffState;
  final bool fromCompletedProjectsProfileDetail;

  String get _sectionTitle => title ?? AppStrings.tabMembers;

  @override
  Widget build(BuildContext context) {
    if (watchBlocForVffState) {
      return BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
        buildWhen: (prev, curr) =>
            prev is ProjectDetailLoaded &&
            curr is ProjectDetailLoaded &&
            (prev.project.members != curr.project.members ||
                prev.sendingVffUserId != curr.sendingVffUserId),
        builder: (context, detailState) {
          if (detailState is! ProjectDetailLoaded) {
            return const SizedBox.shrink();
          }
          return _buildSection(
            detailState.project,
            detailState.sendingVffUserId,
          );
        },
      );
    }

    return _buildSection(project, sendingVffUserId);
  }

  Widget _buildSection(ProjectDetailEntity detail, String? sendingId) {
    final canInteract = detail.canReviewMemberProfiles;
    return ProjectMembersPreviewSection(
      project: detail,
      title: _sectionTitle,
      onMemberTap: canInteract ? onMemberTap : null,
      onSendVffRequest: canInteract ? onSendVffRequest : null,
      sendingVffUserId: sendingId,
      fromCompletedProjectsProfileDetail: fromCompletedProjectsProfileDetail,
    );
  }
}
