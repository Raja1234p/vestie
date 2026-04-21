import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

String formatProjectInfoAmount(double value) {
  return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
}

class ProjectInfoGoalRow extends StatelessWidget {
  final double goal;
  final double current;

  const ProjectInfoGoalRow({
    super.key,
    required this.goal,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = formatProjectInfoAmount(current);
    final goalValue = formatProjectInfoAmount(goal);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.lato(fontSize: 28.sp, color: AppColors.textPrimary),
        children: [
          TextSpan(
            text: AppStrings.goalPrefix,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: '\$$currentValue',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: '  / \$$goalValue',
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectInfoDeadlineRow extends StatelessWidget {
  final String endsIn;

  const ProjectInfoDeadlineRow({super.key, required this.endsIn});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 14.w, color: AppColors.textBody),
        SizedBox(width: 6.w),
        AppText(
          '${AppStrings.labelEndsIn} ',
          style: GoogleFonts.lato(fontSize: 13.sp, color: AppColors.textBody),
        ),
        AppText(
          endsIn,
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
