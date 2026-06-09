import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/models/bank_link_onboarding_result.dart';
import 'package:vestie/features/bank_accounts/presentation/widgets/bank_account_manage_row.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_empty_view.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_primary_button.dart';
import '../cubit/wallet_transaction_cubit.dart';

/// Pick linked bank for withdrawal (Week 7).
class SelectBankAccountScreen extends StatefulWidget {
  const SelectBankAccountScreen({super.key});

  @override
  State<SelectBankAccountScreen> createState() => _SelectBankAccountScreenState();
}

class _SelectBankAccountScreenState extends State<SelectBankAccountScreen> {
  final _listBankAccounts = ServiceLocator.instance.listBankAccountsUseCase;
  List<BankAccountEntity> _banks = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _listBankAccounts(forceRefresh: true);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = FailureMapper.userMessage(f);
        _banks = const [];
      }),
      (banks) => setState(() {
        _loading = false;
        _banks = banks;
      }),
    );
  }

  Future<void> _reloadInPlace() async {
    final result = await _listBankAccounts(forceRefresh: true);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = FailureMapper.userMessage(f);
        _banks = const [];
      }),
      (banks) => setState(() {
        _error = null;
        _banks = banks;
      }),
    );
  }

  Future<void> _addBankAccount() async {
    final result = await context.push<BankLinkOnboardingResult>(
      AppRoutes.bankLinkOnboarding,
    );
    if (!mounted || result == null) return;
    switch (result) {
      case BankLinkOnboardingResult.linked:
        await _reloadInPlace();
      case BankLinkOnboardingResult.completed:
      case BankLinkOnboardingResult.incomplete:
        AppToast.showInfo(context, AppStrings.bankLinkOnboardingIncompleteHint);
      case BankLinkOnboardingResult.canceled:
        AppToast.showError(context, AppStrings.bankLinkOnboardingCanceled);
    }
  }

  void _onSelect(BankAccountEntity bank) {
    context.read<WalletTransactionCubit>().selectBankAccount(
          bankAccountId: bank.id,
          displayName: bank.displayName,
        );
    context.push(AppRoutes.transactionConfirmation);
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = !_loading && _banks.isEmpty;
    final loadFailed = !_loading && _error != null && _banks.isEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.selectBankAccountTitle,
              onBack: context.pop,
            ),
            Expanded(
              child: _loading
                  ? const PaymentCardListShimmer()
                  : loadFailed || isEmpty
                      ? PaymentEmptyView(
                          title: AppStrings.emptyMyAccountsTitle,
                          subtitle: _error ?? AppStrings.emptyMyAccountsSubtitle,
                        )
                      : ListView.separated(
                          padding: FlowScreenFooterInsets.listPadding(context),
                          itemCount: _banks.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: AppDimens.paymentMethodRowGap),
                          itemBuilder: (context, index) {
                            final bank = _banks[index];
                            return BankAccountManageRow(
                              account: bank,
                              showChevron: false,
                              onTap: () => _onSelect(bank),
                            );
                          },
                        ),
            ),
            if (isEmpty || (!_loading && _banks.isNotEmpty))
              FlowScreenFooter(
                child: PaymentPrimaryButton(
                  label: AppStrings.btnAddBankAccount,
                  onTap: _loading ? null : _addBankAccount,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
