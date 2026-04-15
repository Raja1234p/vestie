import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../domain/entities/transaction.dart';

class TxListItem extends StatelessWidget {
  final Transaction tx;
  const TxListItem({super.key, required this.tx});

  Color get _iconBg {
    switch (tx.type) {
      case TransactionType.deposit:
        return AppColors.txDepositBg;
      case TransactionType.contribution:
        return AppColors.txContribBg;
      default:
        return AppColors.txBorrowBg;
    }
  }

  Color get _iconColor {
    switch (tx.type) {
      case TransactionType.deposit:
        return AppColors.txDepositIcon;
      case TransactionType.contribution:
        return AppColors.txContribIcon;
      default:
        return AppColors.txBorrowIcon;
    }
  }

  String get _svgIcon {
    switch (tx.type) {
      case TransactionType.deposit:
        return AppAssets.iconDeposit;
      case TransactionType.contribution:
        return AppAssets.iconContribution;
      default:
        return AppAssets.iconDollarCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
            child: Center(
              child: SvgPicture.asset(
                _svgIcon,
                width: 18.w,
                height: 18.w,
                colorFilter: ColorFilter.mode(_iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  tx.date,
                  style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.textBody),
                ),
              ],
            ),
          ),
          AppText(
            tx.formattedAmount,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: tx.isPositive ? AppColors.txPositive : AppColors.txNegative,
            ),
          ),
        ],
      ),
    );
  }
}
