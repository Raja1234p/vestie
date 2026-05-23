import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/presentation/widgets/wallet_detail_summary_row.dart';

/// Repay confirm — matches [WalletDepositConfirmSection] layout.
class BorrowRepayConfirmSection extends StatelessWidget {
  final BorrowRepayConfirmRouteArgs args;

  const BorrowRepayConfirmSection({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.v10,
        AppDimens.p16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.labelRepayAmount,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: AppDimens.v8),
          AppText(
            AppFormatters.formatCurrency(args.repayAmount),
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
                  label: AppStrings.labelFrom,
                  value: args.paymentMethodLabel,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.myBorrowBreakdownProjectNameLabel,
                  value: args.projectName,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.myBorrowDueDateLabel,
                  value: args.dueDateLabel,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                ),
                if (args.showsPenalty) ...[
                  SizedBox(height: AppDimens.v14),
                  WalletDetailSummaryRow(
                    label: AppStrings.penaltyPenaltyLabel,
                    value: AppStrings.borrowRepayPenaltyValue(
                      args.penaltyPercent,
                      AppFormatters.formatCurrency(args.penaltyAmount),
                    ),
                    labelColor: AppColors.neutral700,
                    valueColor: AppColors.red900,
                    valueWeight: FontWeight.w600,
                  ),
                ],
                SizedBox(height: AppDimens.v14),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.neutral400,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.myBorrowTotalRepaymentLabel,
                  value: AppFormatters.formatCurrency(args.totalRepayment),
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
