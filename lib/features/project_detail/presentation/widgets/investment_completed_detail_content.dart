import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/models/completed_project_notice_copy.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/announcement_card.dart';
import 'package:vestie/features/project_detail/presentation/widgets/completed_project_notice_bar.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';

/// Completed investment project detail (Figma — raised, returns CTA, notice, members).
class InvestmentCompletedDetailContent extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity> onMemberTap;
  final VoidCallback? onDeleteAnnouncement;

  const InvestmentCompletedDetailContent({
    super.key,
    required this.project,
    required this.onMemberTap,
    this.onDeleteAnnouncement,
  });

  @override
  Widget build(BuildContext context) {
    final notice = CompletedProjectNoticeCopy.forCategory(project.category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        AnnouncementCard(
          text: project.announcement,
          canDeleteAnnouncement: project.isModeratorView,
          onDelete: project.isModeratorView ? onDeleteAnnouncement : null,
        ),
        SizedBox(height: 12.h),
        ProjectInfoCard(
          project: project,
          displayAsCompleted: true,
        ),
        SizedBox(height: 16.h),
        AppButton(
          text: project.isModeratorView
              ? AppStrings.btnDistributeFunds
              : AppStrings.btnInvestmentReturns,
          onPressed: () => ProjectDetailNavigationHelpers.openInvestmentReturns(
            context,
            project: project,
          ),
        ),
        SizedBox(height: 16.h),
        CompletedProjectNoticeBar(
          title: notice.title,
          body: notice.body,
        ),
        SizedBox(height: 16.h),
        ProjectMembersPreviewSection(
          project: project,
          onMemberTap: onMemberTap,
          onAddFriend: (member) => ProjectDetailNavigationHelpers.openAddFriendFlow(
            context,
            member,
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
