import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/models/completed_project_notice_copy.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_announcements_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/completed_project_notice_bar.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_info_card.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_members_only_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/investment_returns_notice_pill.dart';

/// Investment post-contribution / completed detail — raised summary, returns CTA, members.
class InvestmentCompletedDetailContent extends StatelessWidget {
  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;
  final Future<bool> Function(String announcementId)? onDeleteAnnouncement;
  final bool hideInvestmentActions;
  final bool membersOnlyLayout;
  final bool displayAsCompleted;
  final bool showCompletedNotice;

  const InvestmentCompletedDetailContent({
    super.key,
    required this.project,
    this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
    this.onDeleteAnnouncement,
    this.hideInvestmentActions = false,
    this.membersOnlyLayout = false,
    this.displayAsCompleted = true,
    this.showCompletedNotice = true,
  });

  @override
  Widget build(BuildContext context) {
    final memberNotice = showCompletedNotice && !project.isModeratorView
        ? CompletedProjectNoticeCopy.forCategory(project.category)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        ProjectAnnouncementsSection(
          project: project,
          onDeleteAnnouncement: onDeleteAnnouncement,
          gapAfter: 12.h,
        ),
        ProjectInfoCard(
          project: project,
          displayAsCompleted: displayAsCompleted,
        ),
        if (!hideInvestmentActions) ...[
          SizedBox(height: 16.h),
          AppButton(
            text: project.isModeratorView
                ? AppStrings.btnDistributeFunds
                : AppStrings.btnInvestmentReturns,
            onPressed: () => ProjectDetailNavigation.openInvestmentReturns(
              context,
              project: project,
            ),
          ),
          if (!project.isModeratorView) ...[
            SizedBox(height: 12.h),
            const InvestmentReturnsNoticePill(),
          ],
        ],
        if (memberNotice != null) ...[
          SizedBox(height: 16.h),
          CompletedProjectNoticeBar(
            title: memberNotice.title,
            body: memberNotice.body,
          ),
        ],
        SizedBox(height: 16.h),
        if (membersOnlyLayout)
          ProjectDetailMembersOnlySection(
            project: project,
            onMemberTap: onMemberTap,
            onSendVffRequest: onSendVffRequest,
            sendingVffUserId: sendingVffUserId,
          )
        else
          ProjectMembersPreviewSection(
            project: project,
            onMemberTap: onMemberTap,
            onSendVffRequest: onSendVffRequest,
            sendingVffUserId: sendingVffUserId,
          ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
