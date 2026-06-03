import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/utils/project_end_relative_label.dart';
import 'package:vestie/core/utils/roi_display_format.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/project_end_and_roi_row.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../domain/entities/project.dart';
import 'project_card_components.dart';
import 'project_card_formatters.dart';

/// Figma-accurate project card.
///
/// Ongoing  : category chip | status badge | project name | goal + progress + date | action button
/// Completed: project-name chip | ✓ Completed badge | "Raised/Total $X" large | button only for Joined
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onAction;

  /// Discover tab — public/private join labels at 18 / w500 (Figma).
  final bool discoverCtaStyle;
  final bool actionLoading;

  /// Profile → Completed Projects: always show View (same card, list context).
  final bool forceShowActionButton;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onAction,
    this.discoverCtaStyle = false,
    this.actionLoading = false,
    this.forceShowActionButton = false,
  });

  /// My Projects: View while ongoing. Joined: View only when `displayStatus` is
  /// On Going; no CTA for Waiting for Approval (see [Project.showsHomeActionButton]).
  bool get _showActionButton =>
      forceShowActionButton || project.showsHomeActionButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.purple300.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBody.withValues(alpha: 0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category / project-name chip + status badge ───
          Row(
            children: [
              ProjectCategoryChip(project: project),
              const Spacer(),
              ProjectStatusBadge(
                status: project.status,
                label: project.statusLabel,
                isDraft: project.isDraft,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // ── Main content differs by status ────────────────
          if (project.status == ProjectStatus.ongoing) ...[
            // Project name
            Text(
              project.name,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.description != null) ...[
                  Expanded(
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: Radius.circular(8.r),
                        color: AppColors.projectCardDescriptionBorder,
                        strokeWidth: 1,
                        dashPattern: const [10, 6],
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          project.description!,
                          style: GoogleFonts.lato(
                            fontSize: 11.sp,
                            color: AppColors.textBody,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ] else
                  const Spacer(),
                Image.asset(
                  project.category.cardImageAsset,
                  width: 100.w,
                  height: 69.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            if (project.goalAmount != null) ...[
              SizedBox(height: 8.h),
              ProjectGoalRow(project: project),
              SizedBox(height: 6.h),
              ProjectProgressBar(progress: project.progress),
              SizedBox(height: 6.h),
              if (_showEndOrRoiRow(project))
                ProjectEndAndRoiRow(
                  endsInRaw: project.endsIn ?? '',
                  roiPercentage: project.roiPercentage,
                  showRoi: project.category.isInvestment,
                ),
            ],
          ] else ...[
            // Completed — project name + raised/invested amount (+ ROI)
            AppText(
              project.name,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            _CompletedAmountRow(project: project),
          ],

          if (_showActionButton) ...[
            SizedBox(height: 12.h),
            ProjectActionButton(
              project: project,
              onTap: onAction,
              discoverCtaStyle: discoverCtaStyle,
              isLoading: actionLoading,
            ),
          ],
        ],
      ),
    );
  }
}

bool _showEndOrRoiRow(Project project) {
  if (ProjectEndRelativeLabel.hasActiveDeadline(project.endsIn)) return true;
  return project.category.isInvestment &&
      isDisplayableRoi(project.roiPercentage);
}

class _CompletedAmountRow extends StatelessWidget {
  const _CompletedAmountRow({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final roiValue = formatRoiPercentDisplay(project.roiPercentage);
    final showRoi =
        project.category.isInvestment && roiValue.isNotEmpty;

    final amountStyle = GoogleFonts.lato(
      fontSize: 22.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    );

    final roiLabelStyle = GoogleFonts.lato(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: AppColors.grey800,
      height: 1.2,
    );
    final roiValueStyle = GoogleFonts.lato(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF000000),
      height: 1.2,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AppText(
            projectRaisedText(project),
            style: amountStyle,
          ),
        ),
        if (showRoi)
          Text.rich(
            TextSpan(
              style: roiLabelStyle,
              children: [
                TextSpan(text: AppStrings.labelRoiColon),
                TextSpan(text: ' $roiValue', style: roiValueStyle),
              ],
            ),
          ),
      ],
    );
  }
}
