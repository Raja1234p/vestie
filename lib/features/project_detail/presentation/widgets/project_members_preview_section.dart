import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../navigation/project_detail_navigation_helpers.dart';
import 'members_tab.dart';
import 'project_detail_view_all_link.dart';

/// Members block on investment / completed detail (title + preview + View All).
class ProjectMembersPreviewSection extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;
  final String title;

  const ProjectMembersPreviewSection({
    super.key,
    required this.project,
    this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
    this.title = AppStrings.tabMembers,
  });

  VoidCallback _openViewAll(BuildContext context) =>
      () => ProjectDetailNavigationHelpers.openGroupMembers(
            context,
            project: project,
          );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AppText(
                title,
                style: GoogleFonts.lato(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral1200,
                ),
              ),
            ),
            ProjectDetailViewAllLink(
              label: AppStrings.viewAllMembers,
              onTap: _openViewAll(context),
              inline: true,
            ),
          ],
        ),
        SizedBox(height: 14.h),
        MembersTab(
          project: project,
          members: project.members,
          onViewAll: _openViewAll(context),
          showViewAllLink: false,
          onMemberTap: onMemberTap,
          onSendVffRequest: onSendVffRequest,
          sendingVffUserId: sendingVffUserId,
        ),
      ],
    );
  }
}
