import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project.dart';
import 'project_card_formatters.dart';

class ProjectGoalRow extends StatelessWidget {
  final Project project;

  const ProjectGoalRow({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final current = formatProjectWhole(project.currentAmount);
    final goal = formatProjectWhole(project.goalAmount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.lato(fontSize: 25.sp, color: AppColors.textBody),
            children: [
              TextSpan(
                text: '${AppStrings.labelGoal} ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '\$$current',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        Padding(
          padding: EdgeInsets.only(bottom: 3.h),
          child: Text(
            '/ \$$goal',
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectProgressBar extends StatelessWidget {
  final double progress;

  const ProjectProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100.r),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 12.h,
        backgroundColor: AppColors.progressBg,
        valueColor: const AlwaysStoppedAnimation(AppColors.progressFill),
      ),
    );
  }
}

class ProjectDateRow extends StatelessWidget {
  final String endsIn;

  const ProjectDateRow({super.key, required this.endsIn});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time_outlined, size: 12.w, color: AppColors.textBody),
        SizedBox(width: 4.w),
        Text(
          '${AppStrings.labelEndsIn} ',
          style: GoogleFonts.lato(fontSize: 13.sp, color: AppColors.textBody),
        ),
        Text(
          endsIn,
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            color: AppColors.textBody,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
