import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Recent Activity empty — 3D glass coin (Figma).
class WalletRecentActivityEmpty extends StatelessWidget {
  const WalletRecentActivityEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.walletEmpty,
              width: 120.w,
              height: 120.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),
            AppText(
              AppStrings.walletEmptyActivityTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.guidelineTitle,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: AppText(
                AppStrings.walletEmptyActivitySubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey900,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
