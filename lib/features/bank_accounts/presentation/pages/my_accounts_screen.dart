import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/bank_accounts/presentation/bank_browser_onboarding_runner.dart';
import 'package:vestie/features/bank_accounts/presentation/cubit/bank_accounts_cubit.dart';
import 'package:vestie/features/bank_accounts/presentation/models/bank_link_onboarding_result.dart';
import 'package:vestie/features/bank_accounts/presentation/widgets/bank_account_list.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_empty_view.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_primary_button.dart';
import 'package:vestie/features/profile/presentation/widgets/profile_sub_header.dart';

/// Profile — manage linked bank accounts (same pattern as payment methods).
class MyAccountsScreen extends StatelessWidget {
  const MyAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    return BlocProvider(
      create: (_) => BankAccountsCubit(
        listBankAccountsUseCase: sl.listBankAccountsUseCase,
      ),
      child: const _MyAccountsBody(),
    );
  }
}

class _MyAccountsBody extends StatelessWidget {
  const _MyAccountsBody();

  Future<void> _addBank(BuildContext context) async {
    final cubit = context.read<BankAccountsCubit>();
    cubit.setLinking(true);
    try {
      final result = await BankBrowserOnboardingRunner.run();
      if (!context.mounted) return;

      switch (result) {
        case BankLinkOnboardingResult.linked:
        case BankLinkOnboardingResult.completed:
          final linked = await cubit.syncAfterLink();
          if (!context.mounted) return;
          if (!linked) {
            AppToast.showInfo(
              context,
              AppStrings.bankLinkOnboardingIncompleteHint,
            );
          }
        case BankLinkOnboardingResult.incomplete:
          AppToast.showInfo(context, AppStrings.bankLinkOnboardingIncompleteHint);
        case BankLinkOnboardingResult.canceled:
          AppToast.showError(context, AppStrings.bankLinkOnboardingCanceled);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.showError(context, e.toString());
      }
    } finally {
      if (context.mounted) {
        cubit.setLinking(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BankAccountsCubit, BankAccountsState>(
      listenWhen: (prev, next) =>
          prev.errorMessage != next.errorMessage &&
          next.errorMessage != null &&
          !next.linking,
      listener: (context, state) {
        AppToast.showError(
          context,
          state.errorMessage ?? AppStrings.bankAccountsLoadFailed,
        );
      },
      builder: (context, state) {
        final isEmpty = !state.loading && state.accounts.isEmpty;
        final loadFailed =
            !state.loading &&
            state.errorMessage != null &&
            state.accounts.isEmpty;

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.selectBankAccountTitle),
                Expanded(
                  child: state.loading
                      ? const PaymentCardListShimmer()
                      : loadFailed || isEmpty
                      ? const PaymentEmptyView(
                          title: AppStrings.emptyMyAccountsTitle,
                          subtitle: AppStrings.emptyMyAccountsSubtitle,
                        )
                      : BankAccountList(
                          accounts: state.accounts,
                          onAdd: () => _addBank(context),
                          addLoading: state.linking,
                        ),
                ),
                if (isEmpty)
                  FlowScreenFooter(
                    child: PaymentPrimaryButton(
                      label: AppStrings.btnAddBankAccount,
                      onTap: state.linking ? null : () => _addBank(context),
                      loading: state.linking,
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
