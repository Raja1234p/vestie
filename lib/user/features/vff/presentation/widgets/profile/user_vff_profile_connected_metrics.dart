import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../models/user_vff_profile_ui_model.dart';

/// Contributions + Projects stat cards (connected VFF profile — Figma).
final class UserVffProfileConnectedMetrics extends StatelessWidget {
  final UserVffProfileUiModel profile;

  const UserVffProfileConnectedMetrics({super.key, required this.profile});

  Widget _card(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              label,
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            SizedBox(height: 8.h),
            AppText(
              value,
              style: GoogleFonts.lato(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.grey1100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = profile.metrics;
    return Row(
      children: [
        _card(AppStrings.userVffContributionsPlural, m.contributionsDisplay),
        SizedBox(width: 10.w),
        _card(
          AppStrings.userVffProjectsLabel,
          m.projectsDisplay ?? '0',
        ),
      ],
    );
  }
}
