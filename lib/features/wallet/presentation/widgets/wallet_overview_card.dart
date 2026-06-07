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
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: AppColors.neutral1100,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                SizedBox(height: 6.h),
                AppText(
                  walletAmount,
                  style: GoogleFonts.lato(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral1100,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          _BorrowedSummaryCard(amount: borrowedAmount),
        ],
      ),
    );
  }
}

class _BorrowedSummaryCard extends StatelessWidget {
  final String amount;

  const _BorrowedSummaryCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            AppStrings.borrowedLabel,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              color: AppColors.neutral1100,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          AppText(
            amount,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral1100,
            ),
          ),
        ],
      ),
    );
  }
}
