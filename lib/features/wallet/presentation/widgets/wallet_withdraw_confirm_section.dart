import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/wallet_withdraw_policy.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'wallet_detail_summary_row.dart';

/// Confirm withdraw — same layout/typography as [WalletDepositConfirmSection].
class WalletWithdrawConfirmSection extends StatelessWidget {
  final WalletTransactionState state;

  const WalletWithdrawConfirmSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final method =
        state.withdrawDeliveryMethod ?? WithdrawDeliveryMethod.standard;
    final isInstant = method == WithdrawDeliveryMethod.instant;
    final toLabel = state.payFromWallet
        ? AppStrings.walletTitle
        : state.selectedCard == null
            ? AppStrings.emptyData
            : '${state.selectedCard!.brandName} - ${state.selectedCard!.last4}';
    final feeAmt = WalletWithdrawPolicy.feeAmount(state.amountParsed, method);
    final feeRow = isInstant
        ? AppStrings.withdrawFeeInstantRow(feeAmt)
        : AppStrings.walletFeeNone;
    final eta = isInstant
        ? AppStrings.withdrawProcessingInstantValue
        : AppStrings.walletProcessingTimeValue;
    final net = WalletWithdrawPolicy.netReceive(state.amountParsed, method);

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
            AppStrings.labelWithdrawalAmount,
            style: GoogleFonts.lato(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
          SizedBox(height: AppDimens.v8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppText(
                  state.formattedAmount,
                  style: GoogleFonts.lato(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutral1200,
                    height: 1.1,
                  ),
                ),
              ),
              if (isInstant) ...[
                SizedBox(width: AppDimens.p8),
                const _WithdrawInstantPill(),
              ],
            ],
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
              AppDimens.p14,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppRadius.r14),
              border: Border.all(color: AppColors.neutral400),
            ),
            child: Column(
              children: [
                WalletDetailSummaryRow(
                  label: AppStrings.walletToLabel,
                  value: toLabel,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                  valueFontSize: 16.sp,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletWithdrawalFeeLabel,
                  value: feeRow,
                  labelColor: AppColors.neutral700,
                  valueColor:
                      isInstant ? AppColors.red900 : AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                  valueFontSize: 16.sp,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletProcessingTimeLabel,
                  value: eta,
                  labelColor: AppColors.neutral700,
                  valueColor: AppColors.neutral1200,
                  valueWeight: FontWeight.w600,
                  valueFontSize: 16.sp,
                ),
                SizedBox(height: AppDimens.v14),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.neutral400,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.labelYouWillReceive,
                  value: AppFormatters.formatCurrency(net),
                  labelColor: AppColors.neutral1200,
                  labelWeight: FontWeight.w600,
                  labelFontSize: 16.sp,
                  valueColor: AppColors.green900,
                  valueWeight: FontWeight.w600,
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

/// Instant pill — Figma: #F5F0FE fill, purple border, lightning PNG + label.
class _WithdrawInstantPill extends StatelessWidget {
  const _WithdrawInstantPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.withdrawInstantIllustration,
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 6.w),
          AppText(
            AppStrings.badgeInstant,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey1100,
            ),
          ),
        ],
      ),
    );
  }
}
