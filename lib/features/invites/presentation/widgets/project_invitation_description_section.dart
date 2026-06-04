import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_text.dart';

/// Description block below stats dividers (`GET …/invites/{code}/preview`).
class ProjectInvitationDescriptionSection extends StatelessWidget {
  final String description;

  const ProjectInvitationDescriptionSection({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final body = description.trim();
    if (body.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          AppStrings.projectInvitationDescription,
          style: GoogleFonts.lato(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 8.h),
        AppText(
          body,
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral1200,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
