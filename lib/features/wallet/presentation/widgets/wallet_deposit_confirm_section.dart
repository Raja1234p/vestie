import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/wallet_deposit_policy.dart';
import 'package:vestie/features/wallet/domain/wallet_ui_constants.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'wallet_detail_summary_row.dart';

/// Confirm deposit — hero amount + breakdown card (Figma).
class WalletDepositConfirmSection extends StatelessWidget {
  final WalletTransactionState state;

  const WalletDepositConfirmSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final fromLabel = state.payFromWallet
        ? AppStrings.walletTitle
        : state.selectedCard == null
            ? AppStrings.emptyData
            : '${state.selectedCard!.brandName} - ${state.selectedCard!.last4}';
    final newBal = WalletDepositPolicy.newBalanceAfter(
      currentBalanceUsd: WalletUiConstants.mockLedgerBalanceUsd,
      depositAmountUsd: state.amountParsed,
    );

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
            AppStrings.labelDepositAmount,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: AppDimens.v8),
          AppText(
            state.formattedAmount,
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
                  value: fromLabel,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletDepositFeeLabel,
                  value: WalletDepositPolicy.feePercentLabel,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.red900,
                  valueWeight: FontWeight.w700,
                ),
                SizedBox(height: AppDimens.v14),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.neutral400,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletNewBalanceAfterLabel,
                  value: AppFormatters.formatCurrency(newBal),
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
