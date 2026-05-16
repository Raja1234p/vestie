import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_assets.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';

enum AppTransactionType { deposit, contribution, borrow, withdrawal, lend }

/// Transaction / ledger list tile — matches project funds contribution history row.
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

  bool get _isPositive => !isNegative;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.projectFundsLedgerCardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.projectFundsLedgerBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _TransactionIcon(isPositive: _isPositive),
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.projectDetailText,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  date,
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.projectFundsLedgerDate,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          AppText(
            '${_isPositive ? '+' : '-'}\$$amount',
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: _isPositive
                  ? AppColors.projectFundsLedgerAmountPositive
                  : AppColors.projectFundsLedgerAmountNegative,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final bool isPositive;

  const _TransactionIcon({required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.projectFundsLedgerIconTileBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.projectFundsLedgerBorder,
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        isPositive
            ? AppAssets.iconDollarCircle
            : AppAssets.iconCircleArrowUp02,
        width: 24.w,
        height: 24.h,
        fit: BoxFit.contain,
      ),
    );
  }
}
