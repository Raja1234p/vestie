import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/models/completed_project_notice_copy.dart';
import 'package:vestie/features/project_detail/presentation/widgets/announcement_card.dart';
import 'package:vestie/features/project_detail/presentation/widgets/completed_project_notice_bar.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation_helpers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';

/// Shared layout: member (or any read-only) view when the project is **completed** —
/// announcement, info card, notice, and members only (no contribute / borrow / tabs).
///
/// Screens own navigation; this widget only composes existing building blocks.
class ProjectDetailUserCompletedContent extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity> onMemberTap;
  final VoidCallback? onDeleteAnnouncement;

  const ProjectDetailUserCompletedContent({
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
        ProjectInfoCard(project: project),
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
