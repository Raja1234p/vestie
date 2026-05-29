import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import '../../domain/wallet_transaction_type.dart';
import '../../domain/withdraw_delivery_method.dart';
import '../cubit/wallet_transaction_cubit.dart';
import '../widgets/wallet_deposit_confirm_section.dart';
import '../widgets/wallet_withdraw_confirm_section.dart';

/// Confirm deposit or withdraw before calling the ledger API.
class TransactionConfirmationScreen extends StatelessWidget {
  const TransactionConfirmationScreen({super.key});

  String _confirmCta(WalletTransactionState state) {
    if (state.transactionType == WalletTransactionType.deposit) {
      return AppStrings.btnConfirmDeposit;
    }
    return state.withdrawDeliveryMethod == WithdrawDeliveryMethod.instant
        ? AppStrings.btnConfirmInstantWithdraw
        : AppStrings.btnConfirmStandardWithdraw;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final isDeposit =
            state.transactionType == WalletTransactionType.deposit;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostAuthHeader(
                  title: isDeposit
                      ? AppStrings.confirmDepositTitle
                      : AppStrings.confirmWithdrawTitle,
                  padding: EdgeInsets.fromLTRB(
                    AppDimens.p16,
                    AppDimens.v16,
                    AppDimens.p16,
                    AppDimens.v8,
                  ),
                  leading: AppBackButton(
                    onPressed: context.pop,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: isDeposit
                      ? WalletDepositConfirmSection(state: state)
                      : WalletWithdrawConfirmSection(state: state),
                ),
                FlowScreenFooter(
                  child: AppButton(
                    text: _confirmCta(state),
                    onPressed: () => context
                        .pushReplacement(AppRoutes.transactionSuccess),
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
