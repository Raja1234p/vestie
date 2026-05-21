import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_purple_dashed_line.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/wallet_withdraw_policy.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'wallet_detail_summary_row.dart';

/// Confirm withdraw — hero amount, optional instant badge, breakdown (Figma).
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
      padding: EdgeInsets.symmetric(horizontal: AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppStrings.labelWithdrawalAmount,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: AppDimens.v8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppText(
                  state.formattedAmount,
                  style: GoogleFonts.lato(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey1100,
                  ),
                ),
              ),
              if (isInstant) const _WithdrawInstantBadge(),
            ],
          ),
          SizedBox(height: AppDimens.v24),
          AppText(
            AppStrings.labelBreakdown,
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
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
                  label: AppStrings.walletToLabel,
                  value: toLabel,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletWithdrawalFeeLabel,
                  value: feeRow,
                  valueColor:
                      isInstant ? AppColors.red700 : AppColors.grey1100,
                  valueWeight: FontWeight.w700,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.walletProcessingTimeLabel,
                  value: eta,
                ),
                SizedBox(height: AppDimens.v14),
                const AppPurpleDashedLine(
                  color: AppColors.purple300,
                  height: 1,
                ),
                SizedBox(height: AppDimens.v14),
                WalletDetailSummaryRow(
                  label: AppStrings.labelYouWillReceive,
                  value: AppFormatters.formatCurrency(net),
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

class _WithdrawInstantBadge extends StatelessWidget {
  const _WithdrawInstantBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.purple100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.purple300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(
            assetPath: AppAssets.iconLightning,
            size: 14.w,
            color: AppColors.primary,
          ),
          SizedBox(width: 4.w),
          AppText(
            AppStrings.badgeInstant,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
