import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Borrow history row on My Borrow Request (Figma).
class MyBorrowHistoryRow extends StatelessWidget {
  final MyBorrowHistoryEntry entry;

  const MyBorrowHistoryRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.projectFundsLedgerCardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.projectFundsLedgerBorder, width: 1),
      ),
      child: Row(
        children: [
          _BorrowHistoryIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  AppFormatters.formatCurrency(entry.amount),
                  style: GoogleFonts.lato(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.projectDetailText,
                  ),
                ),
                SizedBox(height: 2.h),
                AppText(
                  entry.dateLabel,
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.projectFundsLedgerDate,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(entry: entry),
        ],
      ),
    );
  }
}

class _BorrowHistoryIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.projectFundsLedgerIconTileBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.purple300, width: 1),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        AppAssets.transactionTransferOut,
        width: 24.w,
        height: 24.w,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MyBorrowHistoryEntry entry;

  const _StatusBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    final label = entry.statusDisplay.trim().isNotEmpty
        ? entry.statusDisplay.trim()
        : switch (entry.badgeKind) {
            MyBorrowHistoryBadgeKind.approved =>
              AppStrings.borrowHistoryApproved,
            MyBorrowHistoryBadgeKind.cancelled =>
              AppStrings.borrowHistoryCancelled,
            MyBorrowHistoryBadgeKind.rejected =>
              AppStrings.borrowHistoryRejected,
          };

    final (bg, fg) = switch (entry.badgeKind) {
      MyBorrowHistoryBadgeKind.approved => (
        AppColors.badgeCompletedBg,
        AppColors.badgeCompletedText,
      ),
      MyBorrowHistoryBadgeKind.cancelled => (
        AppColors.neutral300,
        AppColors.neutral700,
      ),
      MyBorrowHistoryBadgeKind.rejected => (
        AppColors.borrowVoteDownBg,
        AppColors.red900,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: AppText(
        label,
        style: GoogleFonts.lato(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
