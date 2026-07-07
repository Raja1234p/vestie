import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_category_extensions.dart';

class ProjectCategoryChip extends StatelessWidget {
  final Project project;

  const ProjectCategoryChip({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final iconAsset = project.category.iconAsset;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null)
            SvgPicture.asset(
              iconAsset,
              width: 12.w,
              height: 12.w,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            )
          else
            AppSvgIcon(
              assetPath: AppAssets.projectTypeEmergency,
              size: 12.w,
              color: AppColors.primary,
            ),
          SizedBox(width: 4.w),
          Text(
            project.categoryLabel,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              color: AppColors.textBody,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectStatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final String label;
  final bool isDraft;

  const ProjectStatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.isDraft = false,
  });

  @override
  Widget build(BuildContext context) {
    final completed = status == ProjectStatus.completed;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: completed
              ? const [AppColors.green600, AppColors.green800]
              : isDraft
              ? const [AppColors.grey500, AppColors.grey700]
              : const [AppColors.blue600, AppColors.blue800],
        ),
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color:
                (completed
                        ? AppColors.green800
                        : isDraft
                        ? AppColors.grey700
                        : AppColors.blue800)
                    .withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (completed) ...[
            SvgPicture.asset(
              AppAssets.statusCompletedTick,
              width: 11.w,
              height: 11.w,
            ),
            SizedBox(width: 3.w),
          ],
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}
