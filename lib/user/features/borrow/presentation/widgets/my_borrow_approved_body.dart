import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_detail_summary_row.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';

/// Approved borrow — amount, breakdown card (matches Confirm deposit screen).
class MyBorrowApprovedBody extends StatelessWidget {
  final MyBorrowApprovedUiData data;

  const MyBorrowApprovedBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.v10,
        AppDimens.p16,
        AppDimens.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.myBorrowAmountLabel,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: AppDimens.v8),
          AppText(
            AppFormatters.formatCurrency(data.borrowAmount),
            style: GoogleFonts.lato(
              fontSize: 40.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral1200,
              height: 1.1,
            ),
          ),
          SizedBox(height: AppDimens.v24),
          AppText(
            AppStrings.labelBreakdown,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: AppDimens.v10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppDimens.p14,
              AppDimens.v14,
              AppDimens.p14,
              AppDimens.v14,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppRadius.r14),
              border: Border.all(color: AppColors.neutral400),
            ),
            child: Column(
              children: [
                WalletDetailSummaryRow(
                  label: AppStrings.myBorrowBorrowDateLabel,
                  value: data.borrowDateLabel,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.myBorrowDueDateLabel,
                  value: data.dueDateLabel,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                ),
                SizedBox(height: AppDimens.v14),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.neutral400,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.myBorrowTotalRepaymentLabel,
                  value: AppFormatters.formatCurrency(data.totalRepayment),
                  labelColor: AppColors.neutral1200,
                  labelWeight: FontWeight.w600,
                  valueColor: AppColors.green900,
                  valueWeight: FontWeight.w700,
                  valueFontSize: 18.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
