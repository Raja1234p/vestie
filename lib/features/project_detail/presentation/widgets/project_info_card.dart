import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/project.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_info_card_chips.dart';
import 'project_info_card_rows.dart';

/// Project info card: category chip, status badge, goal amount, deadline.
class ProjectInfoCard extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectInfoCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Category chip + Status badge ──────────────
          Row(
            children: [
              ProjectInfoCategoryChip(project: project),
              const Spacer(),
              ProjectInfoStatusBadge(status: project.status),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Amount: ongoing = goal + deadline; completed = raised total only (Figma)
          if (project.status == ProjectStatus.completed) ...[
            ProjectInfoRaisedTotalRow(current: project.currentAmount),
          ] else ...[
            ProjectInfoGoalRow(
              goal: project.goalAmount,
              current: project.currentAmount,
            ),
            SizedBox(height: 8.h),
            ProjectInfoDeadlineRow(endsIn: project.endsIn),
          ],
        ],
      ),
    );
  }
}
