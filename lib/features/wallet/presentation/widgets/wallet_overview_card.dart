import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

/// Wallet balance + borrowed summary (Figma wallet tab).
class WalletOverviewCard extends StatelessWidget {
  final String walletAmount;
  final String borrowedAmount;

  const WalletOverviewCard({
    super.key,
    required this.walletAmount,
    required this.borrowedAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  AppStrings.walletBalanceHeading,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    color: AppColors.neutral1200,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  walletAmount,
                  style: GoogleFonts.lato(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral1200,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  AppStrings.borrowedLabel,
                  style: GoogleFonts.lato(
                    fontSize: 12.sp,
                    color: AppColors.neutral1200,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  borrowedAmount,
                  style: GoogleFonts.lato(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral1200,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
