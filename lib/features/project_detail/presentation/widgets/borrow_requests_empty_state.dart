import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Figma empty state when the borrow-requests list is empty.
class BorrowRequestsEmptyState extends StatelessWidget {
  const BorrowRequestsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.borrowRequestsEmptyState,
            width: 100.w,
            height: 100.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h),
          AppText(
            AppStrings.borrowRequestsEmpty,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.projectDetailText,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
