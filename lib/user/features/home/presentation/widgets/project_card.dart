import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/utils/project_end_relative_label.dart';
import 'package:vestie/core/theme/app_colors.dart';
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

  const ProjectCard({
    super.key,
    required this.project,
    required this.onAction,
    this.discoverCtaStyle = false,
    this.actionLoading = false,
  });

  /// My Projects: View while ongoing. Joined: View only when `displayStatus` is
  /// On Going; no CTA for Waiting for Approval (see [Project.showsHomeActionButton]).
  bool get _showActionButton => project.showsHomeActionButton;

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
            if (project.description != null) ...[
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(8.r),
                    color: const Color(0xFFD9D9D9),
                    strokeWidth: 1,
                    dashPattern: const [2, 4],
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                  ),
                  child: Text(
                    project.description!,
                    style: GoogleFonts.lato(
                      fontSize: 11.sp,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
              ),
            ],
            if (project.goalAmount != null) ...[
              SizedBox(height: 8.h),
              ProjectGoalRow(project: project),
              SizedBox(height: 6.h),
              ProjectProgressBar(progress: project.progress),
              SizedBox(height: 6.h),
              if (ProjectEndRelativeLabel.hasDisplayableEnd(project.endsIn))
                ProjectDateRow(endsInRaw: project.endsIn!),
            ],
          ] else ...[
            // Completed — project name + raised/total amount
            AppText(
              project.name,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            AppText(
              projectRaisedText(project),
              style: GoogleFonts.lato(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
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
