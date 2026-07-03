import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/models/completed_project_notice_copy.dart';
import 'package:vestie/features/project_detail/presentation/widgets/completed_project_notice_bar.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_completed_detail_content.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_announcements_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_members_only_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

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
    if (project.category.isInvestment) {
      return InvestmentCompletedDetailContent(
        project: project,
        onSendVffRequest: onSendVffRequest,
        sendingVffUserId: sendingVffUserId,
        hideInvestmentActions: true,
        membersOnlyLayout: true,
      );
    }

    final notice = CompletedProjectNoticeCopy.forCategory(project.category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        ProjectAnnouncementsSection(project: project, gapAfter: 12.h),
        ProjectInfoCard(project: project),
        SizedBox(height: 16.h),
        CompletedProjectNoticeBar(title: notice.title, body: notice.body),
        SizedBox(height: 16.h),
        ProjectDetailMembersOnlySection(
          project: project,
          onSendVffRequest: onSendVffRequest,
          sendingVffUserId: sendingVffUserId,
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
