import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/router/app_routes.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/common/app_button.dart';
import '../../../../../core/widgets/common/app_numpad.dart';
import '../../../../../core/widgets/text/app_text.dart';
import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_transaction_cubit.dart';

class TransactionAmountScreen extends StatelessWidget {
  const TransactionAmountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final cubit = context.read<WalletTransactionCubit>();
        final isDeposit = state.transactionType == WalletTransactionType.deposit;
        final title = isDeposit ? AppStrings.depositFundsTitle : AppStrings.withdrawFundsTitle;
        final subtitle = isDeposit ? AppStrings.depositAmountSubtitle : AppStrings.withdrawAmountSubtitle;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // ── Top bar ─────────────────────────────────────
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          cubit.reset();
                          context.pop();
                        },
                        child: Icon(Icons.close_rounded,
                            size: 24.w, color: AppColors.textPrimary),
                      ),
                      Expanded(
                        child: AppText(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBody,
                          ),
                        ),
                      ),
                      SizedBox(width: 24.w), // invisible placeholder
                    ],
                  ),
                ),
              ),

              // ── Amount display ───────────────────────────────
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      subtitle,
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        color: AppColors.textBody,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    AppText(
                      state.amountDigits.isEmpty ? '\$0.00' : state.formattedAmount,
                      style: GoogleFonts.lato(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: AppButton(
                        text: AppStrings.btnContinue,
                        onPressed: () {
                          if (state.amountDigits.isEmpty) return;
                          
                          // Navigate to Select Payment Method card sheet
                          // As per our profile implementation, we can push the payment methods screen as selection mode
                          context.push(AppRoutes.selectPaymentMethod).then((selectedCard) {
                             if (selectedCard != null && context.mounted) {
                               // Assuming the list returns a card
                               cubit.selectCard(selectedCard as dynamic);
                               // Automatically proceed to confirmation
                               context.push(AppRoutes.transactionConfirmation);
                             }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── Numeric keypad ───────────────────────────────
              AppNumpad(
                onDigit: cubit.appendAmountDigit,
                onBackspace: cubit.removeAmountDigit,
              ),
            ],
          ),
        );
      },
    );
  }
}
