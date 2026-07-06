import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';

/// Transaction history empty — coin illustration (profile ledger).
class TransactionHistoryEmptyView extends StatelessWidget {
  const TransactionHistoryEmptyView({
    super.key,
    this.isFilterEmpty = false,
  });

  /// When true, [all] transactions exist but the active filter has no matches.
  final bool isFilterEmpty;

  @override
  Widget build(BuildContext context) {
    final title = isFilterEmpty
        ? AppStrings.transactionHistoryFilterEmptyTitle
        : AppStrings.transactionHistoryEmptyTitle;
    final subtitle = isFilterEmpty
        ? AppStrings.transactionHistoryFilterEmptySubtitle
        : AppStrings.transactionHistoryEmptySubtitle;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFilterEmpty) ...[
              Image.asset(
                AppAssets.walletEmpty,
                width: 120.w,
                height: 120.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.h),
            ],
            AppText(
              title,
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
                subtitle,
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
