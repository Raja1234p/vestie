import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

enum AppTransactionType { deposit, contribution, borrow, withdrawal, lend }

/// When [list], parent [ListView.separated] supplies vertical gap (no tile margin).
enum AppTransactionItemSpacing { standalone, list }

/// Wallet / ledger transaction row (Figma recent activity).
class AppTransactionItem extends StatelessWidget {
  final AppTransactionType type;
  final String title;
  final String date;
  final String amount;
  final bool isNegative;
  final AppTransactionItemSpacing spacing;

  const AppTransactionItem({
    super.key,
    required this.type,
    required this.title,
    required this.date,
    required this.amount,
    required this.isNegative,
    this.spacing = AppTransactionItemSpacing.standalone,
  });

  bool get _isPositive => !isNegative;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: spacing == AppTransactionItemSpacing.standalone
          ? EdgeInsets.only(bottom: 10.h)
          : EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral500, width: 1),
      ),
      child: Row(
        children: [
          _TransactionTypeIcon(type: type),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral1200,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  date,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          AppText(
            '${_isPositive ? '+' : '-'}\$$amount',
            style: GoogleFonts.lato(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: _isPositive ? AppColors.green900 : AppColors.red900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTypeIcon extends StatelessWidget {
  const _TransactionTypeIcon({required this.type});

  final AppTransactionType type;

  String get _asset {
    switch (type) {
      case AppTransactionType.deposit:
        return AppAssets.transactionDeposit;
      case AppTransactionType.contribution:
        return AppAssets.transactionContribution;
      case AppTransactionType.borrow:
        return AppAssets.transactionBorrow;
      case AppTransactionType.withdrawal:
        return AppAssets.transactionContribution;
      case AppTransactionType.lend:
        return AppAssets.transactionContribution;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.purple300, width: 1),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        _asset,
        width: 22.w,
        height: 22.h,
        fit: BoxFit.contain,
      ),
    );
  }
}
