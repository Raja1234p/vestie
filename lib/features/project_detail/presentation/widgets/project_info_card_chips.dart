import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart'
    show ProjectStatus;
import 'package:vestie/user/features/home/domain/entities/project_category_extensions.dart';

class ProjectInfoCategoryChip extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectInfoCategoryChip({super.key, required this.project});

  String? get _iconAsset => project.category.iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.purple300),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_iconAsset != null)
            SvgPicture.asset(
              _iconAsset!,
              width: 13.w,
              height: 13.w,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            )
          else
            AppSvgIcon(
              assetPath: AppAssets.projectTypeEmergency,
              size: 13.w,
              color: AppColors.primary,
            ),
          SizedBox(width: 4.w),
          AppText(
            project.categoryLabel,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              color: AppColors.projectDetailText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectInfoStatusBadge extends StatelessWidget {
  final ProjectDetailEntity project;
  final bool displayAsCompleted;

  const ProjectInfoStatusBadge({
    super.key,
    required this.project,
    this.displayAsCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final completed =
        displayAsCompleted || project.status == ProjectStatus.completed;
    final isDraft = project.isDraftStatus;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: completed
              ? const [AppColors.green600, AppColors.green800]
              : isDraft
              ? const [AppColors.grey500, AppColors.grey700]
              : const [AppColors.blue600, AppColors.blue800],
        ),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: AppText(
        completed && project.status != ProjectStatus.completed
            ? AppStrings.statusCompleted
            : project.statusBadgeLabel,
        style: GoogleFonts.lato(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
        ),
      ),
    );
  }
}
