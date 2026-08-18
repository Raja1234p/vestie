import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/project_end_and_roi_row.dart';
import '../../../../core/widgets/common/project_total_members_row.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';
import 'package:vestie/core/widgets/common/project_cover_image.dart';
import 'package:vestie/core/widgets/common/project_images_viewer.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'project_info_card_chips.dart';
import 'project_info_card_rows.dart';

/// Project info card: category chip, status badge, goal amount, deadline.
class ProjectInfoCard extends StatelessWidget {
  final ProjectDetailEntity project;

  /// Completed investment preview / closed project — “Raised $…” layout.
  final bool displayAsCompleted;

  const ProjectInfoCard({
    super.key,
    required this.project,
    this.displayAsCompleted = false,
  });

  bool get _showsCompletedAmount =>
      displayAsCompleted || project.status == ProjectStatus.completed;

  /// Investment funded / post stop-contributions — “Raised $…” without goal slash.
  bool get _showsRaisedOnlyAmount =>
      _showsCompletedAmount || project.investmentContributionsAreClosed;

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
              ProjectInfoStatusBadge(
                project: project,
                displayAsCompleted: displayAsCompleted,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _showsRaisedOnlyAmount
                    ? ProjectInfoRaisedTotalRow(
                        current: project.raisedDisplayAmount,
                      )
                    : ProjectInfoGoalRow(
                        goal: project.goalAmount,
                        current: project.raisedDisplayAmount,
                      ),
              ),
              SizedBox(width: 8.w),
              ProjectCoverImage(
                coverImageUrl: project.coverImageUrl,
                category: project.category,
                width: 100.w,
                height: 69.h,
                onTap: project.galleryImageUrls.isEmpty
                    ? null
                    : () => ProjectImagesViewer.openGallery(
                        context,
                        coverImageUrl: project.coverImageUrl,
                        images: project.images,
                      ),
              ),
            ],
          ),
          if (!_showsCompletedAmount) ...[
            SizedBox(height: 8.h),
            ProjectEndAndRoiRow(
              endsInRaw: project.endsIn,
              roiPercentage: project.roiPercentage,
              showRoi: project.category.isInvestment,
              compact: true,
            ),
          ],
          if (project.displayMemberCount > 0) ...[
            SizedBox(height: 8.h),
            ProjectTotalMembersRow(
              count: project.displayMemberCount,
              compact: true,
            ),
          ] else if (!_showsCompletedAmount && project.contributorCount > 0) ...[
            SizedBox(height: 8.h),
            ProjectInfoContributorRow(count: project.contributorCount),
          ],
        ],
      ),
    );
  }
}
