import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../../home/domain/entities/project.dart' show ProjectStatus;
import '../../../home/domain/entities/project_category_extensions.dart';

class ProjectInfoCategoryChip extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectInfoCategoryChip({super.key, required this.project});

  String? get _iconAsset => project.category.iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_iconAsset != null)
            SvgPicture.asset(
              _iconAsset!,
              width: 13.w,
              height: 13.w,
              colorFilter:
                  const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            )
          else
            Icon(Icons.beach_access_outlined, size: 13.w, color: AppColors.primary),
          SizedBox(width: 4.w),
          AppText(
            project.categoryLabel,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              color: AppColors.textBody,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectInfoStatusBadge extends StatelessWidget {
  final ProjectStatus status;

  const ProjectInfoStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final ongoing = status == ProjectStatus.ongoing;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ongoing
              ? const [AppColors.blue600, AppColors.blue800]
              : const [AppColors.green600, AppColors.green800],
        ),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: AppText(
        ongoing ? AppStrings.statusOnGoing : AppStrings.statusCompleted,
        style: GoogleFonts.lato(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
        ),
      ),
    );
  }
}
