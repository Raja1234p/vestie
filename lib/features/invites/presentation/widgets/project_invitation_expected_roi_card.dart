import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/roi_display_format.dart';
import 'package:vestie/core/widgets/common/app_text.dart';

/// Investment invite — white ROI row (Figma: Expected ROI + green %).
class ProjectInvitationExpectedRoiCard extends StatelessWidget {
  final double roiPercentage;

  const ProjectInvitationExpectedRoiCard({
    super.key,
    required this.roiPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final value = formatRoiPercentDisplay(roiPercentage);
    if (value.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.purple300),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              AppStrings.projectInvitationExpectedRoi,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.grey900,
              ),
            ),
          ),
          AppText(
            value,
            style: GoogleFonts.lato(
              fontSize: 40.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.green900,
            ),
          ),
        ],
      ),
    );
  }
}
