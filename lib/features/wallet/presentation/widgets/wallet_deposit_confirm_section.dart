import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_purple_dashed_line.dart';
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
      padding: EdgeInsets.symmetric(horizontal: AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.labelDepositAmount,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: AppDimens.v8),
          AppText(
            state.formattedAmount,
            style: GoogleFonts.lato(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.grey1100,
            ),
          ),
          SizedBox(height: AppDimens.v24),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppDimens.p14,
              AppDimens.v14,
              AppDimens.p14,
              AppDimens.v14,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r14),
              border: Border.all(color: AppColors.neutral400),
            ),
            child: Column(
              children: [
                WalletDetailSummaryRow(
                  label: AppStrings.labelFrom,
                  value: fromLabel,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletDepositFeeLabel,
                  value: WalletDepositPolicy.feePercentLabel,
                  valueColor: AppColors.red700,
                  valueWeight: FontWeight.w700,
                ),
                SizedBox(height: AppDimens.v14),
                const AppPurpleDashedLine(
                  color: AppColors.purple300,
                  height: 1,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletNewBalanceAfterLabel,
                  value: AppFormatters.formatCurrency(newBal),
                  valueColor: AppColors.txPositive,
                  valueWeight: FontWeight.w800,
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
