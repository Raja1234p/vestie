import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

enum AppTransactionType { deposit, contribution, borrow, withdrawal, lend }

/// Unified Transaction List Item for use in Wallet and Profile features.
/// Adheres to Figma node 6506:4709 specifications.
class AppTransactionItem extends StatelessWidget {
  final AppTransactionType type;
  final String title;
  final String date;
  final String amount;
  final bool isNegative;

  const AppTransactionItem({
    super.key,
    required this.type,
    required this.title,
    required this.date,
    required this.amount,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral500),
      ),
      child: Row(
        children: [
          // ── Icon ────────────────────────────────────────────────────────
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: _getBgColor(),
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.all(8.r),
            child: SvgPicture.asset(
              _getIconPath(),
              colorFilter: ColorFilter.mode(_getIconColor(), BlendMode.srcIn),
            ),
          ),
          SizedBox(width: 12.w),

          // ── Title & Date ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                AppText(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),

          // ── Amount ──────────────────────────────────────────────────────
          AppText(
            '${isNegative ? '-' : '+'}\$$amount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isNegative ? AppColors.red900 : AppColors.green900,
                ),
          ),
        ],
      ),
    );
  }

  Color _getBgColor() {
    switch (type) {
      case AppTransactionType.deposit:
        return AppColors.txDepositBg;
      case AppTransactionType.contribution:
        return AppColors.txContribBg;
      case AppTransactionType.borrow:
      case AppTransactionType.withdrawal:
      case AppTransactionType.lend:
        return AppColors.txBorrowBg;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case AppTransactionType.deposit:
        return AppColors.txDepositIcon;
      case AppTransactionType.contribution:
        return AppColors.txContribIcon;
      case AppTransactionType.borrow:
      case AppTransactionType.withdrawal:
      case AppTransactionType.lend:
        return AppColors.txBorrowIcon;
    }
  }

  String _getIconPath() {
    switch (type) {
      case AppTransactionType.deposit:
        return AppAssets.iconDeposit;
      case AppTransactionType.contribution:
        return AppAssets.iconContribution;
      case AppTransactionType.borrow:
      case AppTransactionType.lend:
      case AppTransactionType.withdrawal:
        return AppAssets.iconDollarCircle;
    }
  }
}
