import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/router/app_routes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/common/app_button.dart';
import '../../../../../core/widgets/common/app_back_button.dart';
import '../../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../../core/widgets/common/post_auth_header.dart';
import '../../../../../core/widgets/text/app_text.dart';
import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_transaction_cubit.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  const TransactionConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final isDeposit = state.transactionType == WalletTransactionType.deposit;
        final title = isDeposit ? AppStrings.confirmDepositTitle : AppStrings.confirmWithdrawTitle;
        final card = state.selectedCard;
        const currentWalletBalance = 2340.0;
        final newBalance = isDeposit
            ? currentWalletBalance + state.amountParsed
            : currentWalletBalance - state.amountParsed;
        final methodLabel = card == null
            ? AppStrings.emptyData
            : '${card.brandName} - ${card.maskedNumber.replaceAll('•', '').trim()}';
        final detailsTitle = isDeposit
            ? AppStrings.walletDepositDetailsTitle
            : AppStrings.walletWithdrawDetailsTitle;
        final amountLabel = isDeposit
            ? AppStrings.walletDepositingLabel
            : AppStrings.walletWithdrawingLabel;
        final methodRowLabel = isDeposit
            ? AppStrings.walletMethodLabel
            : AppStrings.walletToLabel;
        final feeLabel = isDeposit
            ? AppStrings.walletDepositFeeLabel
            : AppStrings.walletWithdrawalFeeLabel;
        final feeValue = AppStrings.walletFeeNone;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostAuthHeader(
                  title: title,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  leading: AppBackButton(
                    onPressed: context.pop,
                    color: AppColors.textPrimary,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 10),
                  child: AppText(
                    detailsTitle,
                    style: GoogleFonts.lato(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey1100,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.neutral400),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(amountLabel, state.formattedAmount),
                        SizedBox(height: 15.h),
                        _buildSummaryRow(methodRowLabel, methodLabel),
                        SizedBox(height: 15.h),
                        _buildSummaryRow(feeLabel, feeValue),
                        if (!isDeposit) ...[
                          SizedBox(height: 15.h),
                          _buildSummaryRow(
                            AppStrings.walletProcessingTimeLabel,
                            AppStrings.walletProcessingTimeValue,
                          ),
                        ],
                        SizedBox(height: 15.h),
                        Divider(height: 1, color: AppColors.grey400),
                        SizedBox(height: 15.h),
                        _newBalanceRow(
                          AppStrings.walletNewBalanceAfterLabel,
                          '\$${newBalance.toStringAsFixed(2)}',
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SafeArea(
                  top: false,
                  minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  child: AppButton(
                    text: isDeposit ? AppStrings.depositFundsTitle : AppStrings.withdrawFundsTitle,
                    color: AppColors.cardActionBtn,
                    useGradient: false,
                    hasShadow: false,
                    onPressed: () => context.pushReplacement(AppRoutes.transactionSuccess),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            color: AppColors.textBody,
          ),
        ),
        AppText(
          value,
          style: GoogleFonts.lato(
            fontSize: highlight ? 16.sp : 16.sp,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
  Widget _newBalanceRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            color:  Colors.black,
          ),
        ),
        AppText(
          value,
          style: GoogleFonts.lato(
            fontSize: highlight ? 18.sp : 18.sp,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

}
