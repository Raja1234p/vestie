import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_announcements_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_wallet_actions.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';

import 'project_detail_tab_section.dart';

/// Default member project detail body (announcement, wallet, tabs).
class ProjectDetailMemberScrollContent extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity> onMemberTap;

  const ProjectDetailMemberScrollContent({
    super.key,
    required this.project,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 12.h),
        ProjectAnnouncementsSection(project: project, gapAfter: 12.h),
        ProjectInfoCard(project: project),
        SizedBox(height: 16.h),
        ProjectDetailWalletActions(project: project),
        SizedBox(height: 20.h),
        ProjectDetailTabSection(project: project, onMemberTap: onMemberTap),
        SizedBox(height: 32.h),
      ],
    );
  }
}
