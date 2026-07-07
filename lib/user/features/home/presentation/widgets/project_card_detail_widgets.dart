import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/utils/project_end_relative_label.dart';
import '../../domain/entities/project.dart';
import 'project_card_formatters.dart';

class ProjectGoalRow extends StatelessWidget {
  final Project project;

  const ProjectGoalRow({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final current = formatProjectWhole(project.currentAmount);
    final goal = formatProjectWhole(project.goalAmount);
    final label = project.investmentContributionsAreClosed
        ? AppStrings.labelRaised
        : AppStrings.labelGoal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.lato(fontSize: 25.sp, color: AppColors.textBody),
            children: [
              TextSpan(
                text: '$label ',
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
  final String endsInRaw;

  const ProjectDateRow({super.key, required this.endsInRaw});

  @override
  Widget build(BuildContext context) {
    final emphasis = ProjectEndRelativeLabel.emphasis(endsInRaw);
    if (emphasis.isEmpty) return const SizedBox.shrink();

    final full = ProjectEndRelativeLabel.isFullSentence(endsInRaw);

    const endsInColor = AppColors.grey800; // #5E5783
    const durationColor = Color(0xFF000000);
    final labelStyle = GoogleFonts.lato(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: endsInColor,
      height: 1.2,
    );
    final durationStyle = GoogleFonts.lato(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: durationColor,
      height: 1.2,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSvgIcon(
          assetPath: AppAssets.projectCardCalendar,
          size: 12,
          color: endsInColor,
        ),
        SizedBox(width: 6.w),
        if (full)
          Text(emphasis, style: durationStyle)
        else
          Text.rich(
            TextSpan(
              style: labelStyle,
              children: [
                TextSpan(text: '${AppStrings.labelEndsIn} '),
                TextSpan(text: emphasis, style: durationStyle),
              ],
            ),
          ),
      ],
    );
  }
}
