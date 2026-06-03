import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/payment_methods/domain/payment_methods_cache.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_picker_behavior.dart';
import 'package:vestie/core/utils/wallet_withdraw_validation.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import '../../domain/wallet_transaction_type.dart';
import '../../domain/withdraw_delivery_method.dart';
import '../cubit/wallet_deposit_cubit.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_transaction_cubit.dart';
import '../cubit/wallet_withdraw_cubit.dart';
import '../widgets/wallet_deposit_confirm_section.dart';
import '../widgets/wallet_withdraw_confirm_section.dart';

/// Confirm deposit or withdraw before calling APIs.
class TransactionConfirmationScreen extends StatefulWidget {
  const TransactionConfirmationScreen({super.key});

  @override
  State<TransactionConfirmationScreen> createState() =>
      _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState
    extends State<TransactionConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tx = context.read<WalletTransactionCubit>().state;
      if (tx.transactionType == WalletTransactionType.withdraw) {
        final balanceErr =
            WalletWithdrawValidation.validateForWithdraw(tx.amountParsed);
        if (balanceErr != null) {
          AppSnackBar.showError(context, balanceErr);
          return;
        }
        final method =
            tx.withdrawDeliveryMethod ?? WithdrawDeliveryMethod.standard;
        context.read<WalletWithdrawCubit>().loadPreview(
              amount: tx.amountParsed,
              method: method,
              bankAccountId: tx.selectedBankAccountId,
            );
      }
    });
  }

  String _confirmCta(WalletTransactionState state) {
    if (state.transactionType == WalletTransactionType.deposit) {
      return AppStrings.btnConfirmDeposit;
    }
    return state.withdrawDeliveryMethod == WithdrawDeliveryMethod.instant
        ? AppStrings.btnConfirmInstantWithdraw
        : AppStrings.btnConfirmStandardWithdraw;
  }

  Future<void> _onConfirm(
    BuildContext context,
    WalletTransactionState txState,
  ) async {
    if (txState.transactionType == WalletTransactionType.deposit) {
      final cardId = txState.selectedCard?.id.trim() ?? '';
      if (txState.payFromWallet || cardId.isEmpty) {
        AppSnackBar.showError(context, AppStrings.depositSelectCardRequired);
        return;
      }
      await context.read<WalletDepositCubit>().submitDeposit(
            amount: txState.amountParsed,
            paymentMethodId: cardId,
          );
      return;
    }
    final balanceErr =
        WalletWithdrawValidation.validateForWithdraw(txState.amountParsed);
    if (balanceErr != null) {
      AppSnackBar.showError(context, balanceErr);
      return;
    }
    final bankId = txState.selectedBankAccountId;
    if (bankId == null || bankId.isEmpty) {
      AppSnackBar.showError(context, AppStrings.withdrawSelectBankRequired);
      return;
    }
    final method =
        txState.withdrawDeliveryMethod ?? WithdrawDeliveryMethod.standard;
    await context.read<WalletWithdrawCubit>().submit(
          amount: txState.amountParsed,
          method: method,
          bankAccountId: bankId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WalletDepositCubit, WalletDepositState>(
          listenWhen: (p, c) =>
              p.failure != c.failure ||
              p.isSuccess != c.isSuccess ||
              p.message != c.message,
          listener: (context, depositState) async {
            if (depositState.failure != null) {
              AppToast.showError(
                context,
                FailureMapper.userMessage(depositState.failure!),
              );
            }
            if (depositState.isSuccess && context.mounted) {
              await context.read<WalletCubit>().load(forceRefresh: true);
              if (!context.mounted) return;
              context.pushReplacement(AppRoutes.transactionSuccess);
            }
          },
        ),
        BlocListener<WalletWithdrawCubit, WalletWithdrawState>(
          listenWhen: (p, c) => p.failure != c.failure || p.isSuccess != c.isSuccess,
          listener: (context, withdrawState) async {
            if (withdrawState.failure != null) {
              AppSnackBar.showError(
                context,
                FailureMapper.userMessage(withdrawState.failure!),
              );
            }
            if (withdrawState.isSuccess && context.mounted) {
              await context.read<WalletCubit>().load(forceRefresh: true);
              if (!context.mounted) return;
              context.pushReplacement(AppRoutes.transactionSuccess);
            }
          },
        ),
      ],
      child: BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
        builder: (context, state) {
          final isDeposit =
              state.transactionType == WalletTransactionType.deposit;
          final depositState = isDeposit
              ? context.watch<WalletDepositCubit>().state
              : null;
          final depositSubmitting = depositState?.isSubmitting ?? false;
          final withdrawSubmitting = !isDeposit
              ? context.watch<WalletWithdrawCubit>().state.isSubmitting
              : false;
          final busy = depositSubmitting || withdrawSubmitting;

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
                      onPressed: busy ? () {} : () => context.pop(),
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: isDeposit
                        ? WalletDepositConfirmSection(
                            state: state,
                            depositErrorMessage: depositState?.failure != null
                                ? _depositErrorHint(depositState!)
                                : null,
                            onChangePaymentMethod:
                                _canChangeDepositCard(state)
                                    ? () =>
                                        _openDepositCardPicker(context, state)
                                    : null,
                          )
                        : WalletWithdrawConfirmSection(
                            txState: state,
                            withdrawState:
                                context.watch<WalletWithdrawCubit>().state,
                          ),
                  ),
                  FlowScreenFooter(
                    child: AppButton(
                      text: _confirmCta(state),
                      isLoading: busy,
                      onPressed: busy ? null : () => _onConfirm(context, state),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static bool _canChangeDepositCard(WalletTransactionState state) {
    if (state.selectedCard == null) return false;
    final count = PaymentMethodsCache.value?.length ?? 0;
    return count > 1;
  }

  static String _depositErrorHint(WalletDepositState depositState) {
    final apiMessage = depositState.message?.trim();
    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }
    if (depositState.failure != null) {
      return FailureMapper.userMessage(depositState.failure!);
    }
    return AppStrings.depositCardInsufficientHint;
  }

  Future<void> _openDepositCardPicker(
    BuildContext context,
    WalletTransactionState txState,
  ) async {
    final previousCardId = txState.selectedCard?.id;
    await context.push(
      AppRoutes.selectPaymentMethod,
      extra: PaymentMethodPickerBehavior.depositFlowChangeCard,
    );
    if (!context.mounted) return;
    final newCardId =
        context.read<WalletTransactionCubit>().state.selectedCard?.id;
    if (newCardId != null &&
        newCardId.isNotEmpty &&
        newCardId != previousCardId) {
      context.read<WalletDepositCubit>().clearFailure();
    }
  }
}
