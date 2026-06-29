import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_voting_entities.dart';

/// Week 11+ status banner — driven by [ProjectDetailEntity.projectBannerStatus].
class ProjectDetailStatusBanner extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectDetailStatusBanner({super.key, required this.project});

  Color get _backgroundColor => switch (project.projectBannerStatus) {
    ProjectDetailBannerStatus.ongoing => AppColors.green100,
    ProjectDetailBannerStatus.completed => AppColors.blue100,
    ProjectDetailBannerStatus.cancelled => AppColors.red100,
  };

  Color get _borderColor => switch (project.projectBannerStatus) {
    ProjectDetailBannerStatus.ongoing => AppColors.green300,
    ProjectDetailBannerStatus.completed => AppColors.blue300,
    ProjectDetailBannerStatus.cancelled => AppColors.red300,
  };

  Color get _textColor => switch (project.projectBannerStatus) {
    ProjectDetailBannerStatus.ongoing => AppColors.green1000,
    ProjectDetailBannerStatus.completed => AppColors.blue1000,
    ProjectDetailBannerStatus.cancelled => AppColors.red1000,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _borderColor),
      ),
      child: AppText(
        project.projectBannerLabel,
        style: GoogleFonts.lato(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
