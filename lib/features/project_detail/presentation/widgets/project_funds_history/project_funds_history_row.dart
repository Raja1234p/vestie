import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';

/// Single ledger row on project funds history (Figma).
class ProjectFundsHistoryRow extends StatelessWidget {
  final ProjectFundsHistoryEntryArgs entry;

  const ProjectFundsHistoryRow({super.key, required this.entry});

  bool get _isContribution => entry.amount >= 0;

  static String formatSignedAmount(double amount) {
    final n = amount.abs().round();
    final formatted = n.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ',',
        );
    return amount >= 0 ? '+\$$formatted' : '-\$$formatted';
  }

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
          _LedgerIcon(isContribution: _isContribution),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  entry.memberName,
                  style: GoogleFonts.lato(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.projectDetailText,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  entry.dateLabel,
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
            formatSignedAmount(entry.amount),
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: _isContribution
                  ? AppColors.projectFundsLedgerAmountPositive
                  : AppColors.projectFundsLedgerAmountNegative,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bordered tile; pre-colored SVGs at 24×24 — no tint or inner fill.
class _LedgerIcon extends StatelessWidget {
  final bool isContribution;

  const _LedgerIcon({required this.isContribution});

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
        isContribution
            ? AppAssets.iconDollarCircle
            : AppAssets.transactionTransferOut,
        width: 24.w,
        height: 24.h,
        fit: BoxFit.contain,
      ),
    );
  }
}
