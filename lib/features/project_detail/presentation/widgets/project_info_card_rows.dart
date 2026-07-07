import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/project_end_relative_label.dart';
import '../../../../core/widgets/common/app_svg_icon.dart';
import '../../../../core/widgets/text/app_text.dart';

String formatProjectInfoAmount(double value) {
  return value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

class ProjectInfoGoalRow extends StatelessWidget {
  final double goal;
  final double current;
  final String prefix;

  const ProjectInfoGoalRow({
    super.key,
    required this.goal,
    required this.current,
    this.prefix = AppStrings.goalPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = formatProjectInfoAmount(current);
    final goalValue = formatProjectInfoAmount(goal);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.lato(
          fontSize: 28.sp,
          color: AppColors.projectDetailText,
        ),
        children: [
          TextSpan(
            text: prefix,
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
              color: AppColors.projectDetailText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single headline when the project is complete (Figma: “Raised $5,000” only).
class ProjectInfoRaisedTotalRow extends StatelessWidget {
  final double current;

  const ProjectInfoRaisedTotalRow({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final v = formatProjectInfoAmount(current);
    return RichText(
      text: TextSpan(
        style: GoogleFonts.lato(
          fontSize: 28.sp,
          color: AppColors.projectDetailText,
        ),
        children: [
          TextSpan(
            text: AppStrings.labelRaised,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: '\$$v',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class ProjectInfoContributorRow extends StatelessWidget {
  final int count;

  const ProjectInfoContributorRow({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return AppText(
      AppStrings.projectContributorCountLabel(count),
      style: GoogleFonts.lato(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
      ),
    );
  }
}

class ProjectInfoDeadlineRow extends StatelessWidget {
  final String endsIn;

  const ProjectInfoDeadlineRow({super.key, required this.endsIn});

  @override
  Widget build(BuildContext context) {
    final emphasis = ProjectEndRelativeLabel.emphasis(endsIn);
    if (emphasis.isEmpty) return const SizedBox.shrink();

    final full = ProjectEndRelativeLabel.isFullSentence(endsIn);
    final labelStyle = GoogleFonts.lato(
      fontSize: 13.sp,
      color: AppColors.projectDetailText,
    );
    final durationStyle = GoogleFonts.lato(
      fontSize: 13.sp,
      fontWeight: FontWeight.w800,
      color: AppColors.projectDetailText,
    );

    return Row(
      children: [
        AppSvgIcon(
          assetPath: AppAssets.projectCardCalendar,
          size: 12,
          color: AppColors.grey800,
        ),
        SizedBox(width: 6.w),
        if (full)
          AppText(emphasis, style: durationStyle)
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
