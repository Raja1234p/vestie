import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';

/// Shown when Discover has no projects from the API (before search/filters).
class DiscoverEmptyView extends StatelessWidget {
  const DiscoverEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.discoverEmptyIllustration,
            width: 220.w,
            height: 220.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 28.h),
          Text(
            AppStrings.discoverEmptyTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            AppStrings.discoverEmptySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}
