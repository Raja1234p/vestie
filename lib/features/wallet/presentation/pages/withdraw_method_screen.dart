import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/kyc/presentation/kyc_browser_onboarding_runner.dart';
import 'package:vestie/features/kyc/presentation/models/kyc_onboarding_result.dart';
import 'package:vestie/features/wallet/domain/withdraw_delivery_method.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';
import 'package:vestie/features/wallet/presentation/navigation/wallet_withdraw_navigation.dart';
import 'package:vestie/features/wallet/presentation/widgets/withdraw_method_body.dart';

/// Pick standard vs instant payout before choosing a bank (Figma).
class WithdrawMethodScreen extends StatefulWidget {
  const WithdrawMethodScreen({super.key});

  @override
  State<WithdrawMethodScreen> createState() => _WithdrawMethodScreenState();
}

class _WithdrawMethodScreenState extends State<WithdrawMethodScreen> {
  bool _isContinuing = false;

  Future<void> _onContinueWithdraw(BuildContext context) async {
    if (_isContinuing) return;
    await _runContinueWithdraw(context);
  }

  void _showKycResultToast(BuildContext context, KycOnboardingResult result) {
    switch (result) {
      case KycOnboardingResult.completed:
        AppToast.showSuccess(context, AppStrings.kycOnboardingCompleteHint);
      case KycOnboardingResult.pendingReview:
        AppToast.showInfo(context, AppStrings.kycOnboardingPendingReviewHint);
      case KycOnboardingResult.incomplete:
        AppToast.showError(context, AppStrings.kycOnboardingIncompleteHint);
      case KycOnboardingResult.rejected:
        AppToast.showError(context, AppStrings.kycOnboardingRejectedHint);
      case KycOnboardingResult.canceled:
        AppToast.showError(context, AppStrings.kycOnboardingCanceled);
    }
  }

  Future<void> _runContinueWithdraw(BuildContext context) async {
    setState(() => _isContinuing = true);
    try {
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
          try {
            final result = await KycBrowserOnboardingRunner.run();
            if (!context.mounted) return;
            _showKycResultToast(context, result);
            if (result == KycOnboardingResult.completed) {
              final recheck = await ServiceLocator.instance.getKycStatusUseCase(
                forceRefresh: true,
              );
              if (!context.mounted) return;
              final canProceed =
                  recheck.fold((_) => false, (s) => s.canWithdraw);
              if (canProceed) {
                WalletWithdrawNavigation.continueFromMethod(
                  context,
                  context.read<WalletTransactionCubit>(),
                );
                return;
              }
            }
          } catch (e) {
            if (context.mounted) {
              AppToast.showError(context, e.toString());
            }
          }
        }
        return;
      }

      if (!context.mounted) return;
      WalletWithdrawNavigation.continueFromMethod(
        context,
        context.read<WalletTransactionCubit>(),
      );
    } finally {
      if (mounted) {
        setState(() => _isContinuing = false);
      }
    }
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
                    0,
                  ),
                  leading: IgnorePointer(
                    ignoring: _isContinuing,
                    child: AppBackButton(
                      onPressed: context.pop,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: WithdrawMethodBody(
                    selected: selected,
                    onSelect: cubit.setWithdrawDeliveryMethod,
                    isLoading: _isContinuing,
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
