import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import '../../domain/wallet_transaction_type.dart';
import '../../domain/withdraw_delivery_method.dart';
import '../cubit/wallet_transaction_cubit.dart';

/// Post-submit wallet success (deposit or withdraw).
class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final isDeposit =
            state.transactionType == WalletTransactionType.deposit;
        final amountText = state.formattedAmount;
        return AppSuccessScreen(
          title: isDeposit
              ? AppStrings.depositSuccessTitle
              : AppStrings.withdrawSuccessTitle,
          subtitleWidget: isDeposit
              ? AppText(
                  AppStrings.depositSuccessBody(amountText),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
                    height: 1.35,
                  ),
                )
              : _WithdrawSubtitle(
                  amountText: amountText,
                  method: state.withdrawDeliveryMethod ??
                      WithdrawDeliveryMethod.standard,
                ),
          buttonText: AppStrings.btnDone,
          onButtonPressed: () {
            context.read<WalletTransactionCubit>().reset();
            context.go(AppRoutes.dashboard);
          },
        );
      },
    );
  }
}

class _WithdrawSubtitle extends StatelessWidget {
  final String amountText;
  final WithdrawDeliveryMethod method;

  const _WithdrawSubtitle({
    required this.amountText,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final body = method == WithdrawDeliveryMethod.instant
        ? AppStrings.withdrawSuccessBodyInstant(amountText)
        : AppStrings.withdrawSuccessBodyStandard(amountText);
    return AppText(
      body,
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.grey700,
        height: 1.35,
      ),
    );
  }
}
