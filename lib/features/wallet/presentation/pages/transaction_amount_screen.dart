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
import '../../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../../core/widgets/common/post_auth_header.dart';
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
        final subtitle = AppStrings.addAmount;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthHeader(
                  title: title,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
                  leading: GestureDetector(
                    onTap: () {
                      cubit.reset();
                      context.pop();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 24.w,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Spacer(),
                      AppText(
                        subtitle,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          color: AppColors.textBody,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      AppText(
                        state.amountDigits.isEmpty ? '\$0.00' : state.formattedAmount,
                        style: GoogleFonts.lato(
                          fontSize: 50.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey1100,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: AppButton(
                          text: AppStrings.btnContinue,
                          onPressed: state.amountDigits.isEmpty
                              ? null
                              : () {
                                  context.push(AppRoutes.selectPaymentMethod).then((selectedCard) {
                                    if (selectedCard != null && context.mounted) {
                                      cubit.selectCard(selectedCard as dynamic);
                                      context.push(AppRoutes.transactionConfirmation);
                                    }
                                  });
                                },
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: AppNumpad(
                    onDigit: cubit.appendAmountDigit,
                    onBackspace: cubit.removeAmountDigit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
