import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project.dart';

class ProjectCategoryChip extends StatelessWidget {
  final Project project;

  const ProjectCategoryChip({super.key, required this.project});

  String get _label => project.status == ProjectStatus.completed
      ? project.name
      : project.categoryLabel;

  String? get _iconAsset {
    switch (project.category) {
      case ProjectCategory.vacations:
        return null;
      case ProjectCategory.emergency:
        return AppAssets.iconEmergencyFund;
      case ProjectCategory.investment:
        return AppAssets.iconInvestmentFund;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (_iconAsset != null)
            SvgPicture.asset(
              _iconAsset!,
              width: 12.w,
              height: 12.w,
              colorFilter:
                  const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            )
          else
            Icon(Icons.beach_access_outlined, size: 12.w, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            _label,
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

  const ProjectStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final ongoing = status == ProjectStatus.ongoing;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ongoing
              ? const [AppColors.blue600, AppColors.blue800]
              : const [AppColors.green600, AppColors.green800],
        ),
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color: (ongoing ? AppColors.blue800 : AppColors.green800)
                .withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!ongoing) ...[
            Icon(Icons.check_circle_rounded, size: 11.w, color: AppColors.surface),
            SizedBox(width: 3.w),
          ],
          Text(
            ongoing ? AppStrings.statusOnGoing : AppStrings.statusCompleted,
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
