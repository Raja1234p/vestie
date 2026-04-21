import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../../home/domain/entities/project.dart';

class ProjectInfoCategoryChip extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectInfoCategoryChip({super.key, required this.project});

  IconData get _icon {
    switch (project.category) {
      case ProjectCategory.vacations:
        return Icons.beach_access_outlined;
      case ProjectCategory.emergency:
        return Icons.shield_outlined;
      case ProjectCategory.investment:
        return Icons.account_balance_outlined;
    }
  }

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
          Icon(_icon, size: 13.w, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
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
      child: Text(
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
