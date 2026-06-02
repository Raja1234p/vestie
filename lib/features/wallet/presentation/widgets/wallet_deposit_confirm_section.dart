import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/wallet/domain/wallet_deposit_policy.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'wallet_detail_summary_row.dart';

/// Confirm deposit — hero amount + breakdown card (Figma).
class WalletDepositConfirmSection extends StatelessWidget {
  final WalletTransactionState state;
  final String? depositErrorMessage;
  final VoidCallback? onChangePaymentMethod;

  const WalletDepositConfirmSection({
    super.key,
    required this.state,
    this.depositErrorMessage,
    this.onChangePaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final fromLabel = state.payFromWallet
            ? AppStrings.walletTitle
            : state.selectedCard == null
                ? AppStrings.emptyData
                : '${state.selectedCard!.brandName} - ${state.selectedCard!.last4}';

        final currentBalance = walletState.wallet?.availableBalance ??
            WalletBalanceCache.value?.availableBalance ??
            0;

        final fee = WalletDepositPolicy.platformFee(state.amountParsed);
        final newBal = WalletDepositPolicy.newBalanceAfter(
          currentBalanceUsd: currentBalance,
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
                    InkWell(
                      onTap: onChangePaymentMethod,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: WalletDetailSummaryRow(
                                label: AppStrings.labelFrom,
                                value: fromLabel,
                                labelColor: AppColors.neutral700,
                                valueColor: AppColors.neutral1200,
                                valueWeight: FontWeight.w600,
                              ),
                            ),
                            if (onChangePaymentMethod != null) ...[
                              SizedBox(width: 8.w),
                              AppText(
                                AppStrings.depositChangePaymentMethod,
                                style: GoogleFonts.lato(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.purple900,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (depositErrorMessage != null &&
                        depositErrorMessage!.isNotEmpty) ...[
                      SizedBox(height: AppDimens.v10),
                      AppText(
                        depositErrorMessage!,
                        style: GoogleFonts.lato(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red900,
                          height: 1.35,
                        ),
                      ),
                    ],
                    SizedBox(height: AppDimens.v14),
                    WalletDetailSummaryRow(
                      label: AppStrings.walletDepositFeeLabel,
                      value:
                          '${AppFormatters.formatCurrency(fee)} (${WalletDepositPolicy.feePercentLabel})',
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
      },
    );
  }
}
