import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_announcements_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_members_only_section.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_members_preview_section.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_copy.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_role.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_outcome_amount_card.dart';
import 'package:vestie/features/success_vote/presentation/widgets/success_vote_outcome_vote_summary.dart';

/// Completed project detail — approved, rejected, or refund vote outcome (Figma).
class ProjectDetailCompletedVoteOutcomeContent extends StatelessWidget {
  const ProjectDetailCompletedVoteOutcomeContent({
    super.key,
    required this.project,
    this.onMemberTap,
    this.onSendVffRequest,
    this.sendingVffUserId,
    this.onDeleteAnnouncement,
    this.membersOnlyLayout = false,
  });

  final ProjectDetailEntity project;
  final ValueChanged<MemberEntity>? onMemberTap;
  final ValueChanged<MemberEntity>? onSendVffRequest;
  final String? sendingVffUserId;
  final Future<bool> Function(String announcementId)? onDeleteAnnouncement;
  final bool membersOnlyLayout;

  @override
  Widget build(BuildContext context) {
    final data = successVoteOutcomeUiDataFromProjectDetail(project);
    final role = SuccessVoteOutcomeRole.fromViewerRole(project.viewerRole);
    final variant = completedOutcomeVariantFromProjectDetail(project);
    final copy = SuccessVoteOutcomeCopy.forRole(
      role,
      category: project.category,
      variant: variant,
    );
    final isApproved = data.isApproved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 12.h),
        ProjectAnnouncementsSection(
          project: project,
          onDeleteAnnouncement: onDeleteAnnouncement,
          gapAfter: 12.h,
        ),
        Image.asset(
          isApproved ? AppAssets.successProjectCreated : AppAssets.statusFailure,
          height: 120.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 16.h),
        AppText(
          copy.titleFor(isApproved),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        AppText(
          copy.subtitleFor(isApproved),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey800,
          ),
        ),
        SizedBox(height: 20.h),
        SuccessVoteOutcomeAmountCard(data: data, copy: copy),
        if (project.hasCompletedVoteTallies) ...[
          SizedBox(height: 24.h),
          SuccessVoteOutcomeVoteSummary(data: data, copy: copy),
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
