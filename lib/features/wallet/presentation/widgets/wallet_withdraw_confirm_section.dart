import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/entities/withdrawal_entities.dart';
import 'package:vestie/features/wallet/domain/wallet_withdraw_policy.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_withdraw_cubit.dart';
import 'wallet_detail_summary_row.dart';

/// Confirm withdraw — same layout/typography as [WalletDepositConfirmSection].
class WalletWithdrawConfirmSection extends StatelessWidget {
  final WalletTransactionState txState;
  final WalletWithdrawState withdrawState;

  const WalletWithdrawConfirmSection({
    super.key,
    required this.txState,
    required this.withdrawState,
  });

  @override
  Widget build(BuildContext context) {
    final method =
        txState.withdrawDeliveryMethod ?? WithdrawDeliveryMethod.standard;
    final isInstant = method == WithdrawDeliveryMethod.instant;
    final preview = withdrawState.preview;
    final toLabel = preview?.destinationDisplay ??
        txState.selectedBankDisplayName ??
        AppStrings.emptyData;
    final feeRow = _withdrawFeeLabel(
      isInstant: isInstant,
      preview: preview,
      amount: txState.amountParsed,
      method: method,
    );
    final eta = preview?.processingTime ??
        (isInstant
            ? AppStrings.withdrawProcessingInstantValue
            : AppStrings.walletProcessingTimeValue);
    final net = preview?.youWillReceive ??
        WalletWithdrawPolicy.netReceive(txState.amountParsed, method);

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
                  txState.formattedAmount,
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

bool _previewIsInstant(WithdrawalPreviewEntity preview) =>
    preview.type.toLowerCase() == 'instant';

double _resolvedPreviewFeeAmount(
  WithdrawalPreviewEntity preview,
  double principal,
) {
  if (preview.feeAmount > 0) return preview.feeAmount;
  if (preview.feePercent > 0 && principal > 0) {
    return double.parse(
      (principal * preview.feePercent / 100).toStringAsFixed(2),
    );
  }
  if (preview.youWillReceive > 0 && principal > preview.youWillReceive) {
    return double.parse(
      (principal - preview.youWillReceive).toStringAsFixed(2),
    );
  }
  return 0;
}

String _withdrawFeeLabel({
  required bool isInstant,
  required WithdrawalPreviewEntity? preview,
  required double amount,
  required WithdrawDeliveryMethod method,
}) {
  final instantFromPreview =
      preview != null && _previewIsInstant(preview);
  if (!isInstant && !instantFromPreview) return AppStrings.walletFeeNone;

  if (preview != null) {
    final feeAmount = _resolvedPreviewFeeAmount(preview, amount);
    if (feeAmount <= 0) return AppStrings.walletFeeNone;
    final feePercent = preview.feePercent > 0
        ? preview.feePercent
        : WalletWithdrawPolicy.instantFeeRate * 100;
    return AppStrings.withdrawFeeInstantRow(
      feePercent: feePercent,
      feeAmount: feeAmount,
    );
  }

  return AppStrings.withdrawFeeInstantRow(
    feePercent: WalletWithdrawPolicy.instantFeeRate * 100,
    feeAmount: WalletWithdrawPolicy.feeAmount(amount, method),
  );
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
