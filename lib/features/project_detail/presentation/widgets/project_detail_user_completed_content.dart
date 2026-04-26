import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../models/completed_project_notice_copy.dart';
import 'announcement_card.dart';
import 'completed_project_notice_bar.dart';
import 'members_list.dart';
import 'project_info_card.dart';

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
          isLeader: project.isLeader,
          onDelete:
              project.isLeader ? onDeleteAnnouncement : null,
        ),
        SizedBox(height: 12.h),
        ProjectInfoCard(project: project),
        SizedBox(height: 16.h),
        CompletedProjectNoticeBar(
          title: notice.title,
          body: notice.body,
        ),
        SizedBox(height: 16.h),
        AppText(
          AppStrings.tabMembers,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 32.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey1100,
              ),
        ),
        SizedBox(height: 14.h),
        MembersList(
          members: project.members,
          onMemberTap: onMemberTap,
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
