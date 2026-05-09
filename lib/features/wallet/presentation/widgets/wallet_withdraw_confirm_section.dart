import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/wallet_withdraw_policy.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'wallet_detail_summary_row.dart';

/// Withdraw breakdown + hero amount (Figma confirm withdraw).
class WalletWithdrawConfirmSection extends StatelessWidget {
  final WalletTransactionState state;

  const WalletWithdrawConfirmSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final method =
        state.withdrawDeliveryMethod ?? WithdrawDeliveryMethod.standard;
    final card = state.selectedCard;
    final toLabel = card == null
        ? AppStrings.emptyData
        : '${card.brandName} - ${card.last4}';
    final feeAmt = WalletWithdrawPolicy.feeAmount(state.amountParsed, method);
    final feeRow = method == WithdrawDeliveryMethod.instant
        ? AppStrings.withdrawFeeInstantRow(feeAmt)
        : AppStrings.walletFeeNone;
    final eta = method == WithdrawDeliveryMethod.instant
        ? AppStrings.withdrawProcessingInstantValue
        : AppStrings.walletProcessingTimeValue;
    final net = WalletWithdrawPolicy.netReceive(state.amountParsed, method);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.labelWithdrawalAmount,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              color: AppColors.textBody,
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
          if (method == WithdrawDeliveryMethod.instant) ...[
            SizedBox(height: AppDimens.v10),
            Row(
              children: [
                AppSvgIcon(
                  assetPath: AppAssets.iconLightning,
                  size: AppDimens.iconSmall,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppDimens.p8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.p8,
                    vertical: AppDimens.v4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                    border: Border.all(color: AppColors.purple300),
                  ),
                  child: AppText(
                    AppStrings.badgeInstant,
                    style: GoogleFonts.lato(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppDimens.v16),
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
                WalletDetailSummaryRow(label: AppStrings.walletToLabel, value: toLabel),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletWithdrawalFeeLabel,
                  value: feeRow,
                  valueColor: method == WithdrawDeliveryMethod.instant
                      ? AppColors.red900
                      : AppColors.grey1100,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletProcessingTimeLabel,
                  value: eta,
                ),
                SizedBox(height: AppDimens.v14),
                Divider(height: 1, color: AppColors.grey400),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.labelYouWillReceive,
                  value: AppFormatters.formatCurrency(net),
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
