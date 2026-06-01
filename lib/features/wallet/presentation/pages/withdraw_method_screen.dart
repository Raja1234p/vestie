import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'package:vestie/features/wallet/presentation/widgets/withdraw_method_body.dart';

/// Pick standard vs instant payout before choosing a bank (Figma).
class WithdrawMethodScreen extends StatelessWidget {
  const WithdrawMethodScreen({super.key});

  Future<void> _onContinueWithdraw(BuildContext context) async {
    final kyc = await ServiceLocator.instance.getKycStatusUseCase();
    if (!context.mounted) return;
    final verified = kyc.fold((_) => false, (s) => s.canWithdraw);
    if (!verified) {
      final verify = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.kycRequiredForWithdrawTitle),
          content: Text(AppStrings.kycRequiredForWithdrawBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppStrings.btnCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppStrings.btnVerifyIdentity),
            ),
          ],
        ),
      );
      if (verify == true && context.mounted) {
        final completed = await context.push<bool>(AppRoutes.kycOnboarding);
        if (completed == true && context.mounted) {
          await _onContinueWithdraw(context);
        }
      }
      return;
    }

    if (!context.mounted) return;
    context.push(AppRoutes.selectBankAccount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
          builder: (context, state) {
            final cubit = context.read<WalletTransactionCubit>();
            final selected = state.withdrawDeliveryMethod ??
                WithdrawDeliveryMethod.standard;

            return Column(
              children: [
                PostAuthHeader(
                  title: AppStrings.withdrawMethodTitle,
                  padding: EdgeInsets.fromLTRB(
                    AppDimens.p16,
                    AppDimens.v16,
                    AppDimens.p16,
                    AppDimens.v10,
                  ),
                  leading: AppBackButton(
                    onPressed: context.pop,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: WithdrawMethodBody(
                    selected: selected,
                    onSelect: cubit.setWithdrawDeliveryMethod,
                    onContinue: () => _onContinueWithdraw(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
