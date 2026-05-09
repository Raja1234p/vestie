import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/wallet_ui_constants.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'wallet_detail_summary_row.dart';

/// Deposit breakdown card on the confirm step.
class WalletDepositConfirmSection extends StatelessWidget {
  final WalletTransactionState state;

  const WalletDepositConfirmSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final card = state.selectedCard;
    final methodLabel = card == null
        ? AppStrings.emptyData
        : '${card.brandName} - ${card.last4}';
    final newBal = WalletUiConstants.mockLedgerBalanceUsd + state.amountParsed;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.walletDepositDetailsTitle,
            style: GoogleFonts.lato(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.grey1100,
            ),
          ),
          SizedBox(height: AppDimens.v10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppDimens.p14,
              AppDimens.v14,
              AppDimens.p14,
              AppDimens.v12,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppRadius.r14),
              border: Border.all(color: AppColors.neutral400),
            ),
            child: Column(
              children: [
                WalletDetailSummaryRow(
                  label: AppStrings.walletDepositingLabel,
                  value: state.formattedAmount,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletMethodLabel,
                  value: methodLabel,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletDepositFeeLabel,
                  value: AppStrings.walletFeeNone,
                ),
                SizedBox(height: AppDimens.v14),
                Divider(height: 1, color: AppColors.grey400),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletNewBalanceAfterLabel,
                  value: AppFormatters.formatCurrency(newBal),
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
