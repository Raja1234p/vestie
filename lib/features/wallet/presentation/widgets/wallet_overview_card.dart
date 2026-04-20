import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/text/app_text.dart';

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
          // ── Wallet Amount Left ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  AppStrings.walletAmountLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 4.h),
                AppText(
                  walletAmount,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                        fontFamily: 'SF Pro', // Explicit as per Figma
                      ),
                ),
              ],
            ),
          ),

          // ── Borrowed Card Right ─────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FA).withValues(alpha: 0.8), // Exact from Figma
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.neutral100.withValues(alpha: 0.5),
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  AppStrings.borrowedLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  borrowedAmount,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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
