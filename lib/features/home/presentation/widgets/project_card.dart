import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
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

  const ProjectCard({super.key, required this.project, required this.onAction});

  bool get _showButton =>
      project.status == ProjectStatus.ongoing ||
      project.relation == ProjectRelation.joined;

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
              ProjectStatusBadge(status: project.status),
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
              Text(project.description!,
                  style: GoogleFonts.lato(
                      fontSize: 11.sp, color: AppColors.textBody)),
            ],
            if (project.goalAmount != null) ...[
              SizedBox(height: 8.h),
              ProjectGoalRow(project: project),
              SizedBox(height: 6.h),
              ProjectProgressBar(progress: project.progress),
              SizedBox(height: 6.h),
              ProjectDateRow(endsIn: project.endsIn ?? ''),
            ],
          ] else ...[
            // Completed — raised/total amount as main large text
            Text(
              projectRaisedText(project),
              style: GoogleFonts.lato(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],

          if (_showButton) ...[
            SizedBox(height: 12.h),
            ProjectActionButton(project: project, onTap: onAction),
          ],
        ],
      ),
    );
  }
}
