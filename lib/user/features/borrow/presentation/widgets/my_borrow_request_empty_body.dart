import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Empty My Borrow Request — illustration + copy (Figma).
class MyBorrowRequestEmptyBody extends StatelessWidget {
  const MyBorrowRequestEmptyBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.borrowRequestsEmptyState,
            width: 120.w,
            height: 120.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),
          AppText(
            AppStrings.borrowRequestsEmpty,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.projectDetailText,
            ),
          ),
          SizedBox(height: 8.h),
          AppText(
            AppStrings.borrowRequestsEmptySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
