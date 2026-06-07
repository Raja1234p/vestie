import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/services/bank_accounts_prefetch.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/bank_browser_onboarding_runner.dart';
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
  bool _linking = false;
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

  Future<void> _addBankAccount() async {
    setState(() => _linking = true);
    try {
      final result = await BankBrowserOnboardingRunner.run(
        onBrowserPresented: () {
          if (mounted) setState(() => _linking = false);
        },
      );
      if (!mounted) return;
      if (result == BankLinkOnboardingResult.linked) {
        await BankAccountsPrefetch.refresh();
        if (!mounted) return;
        await _load();
        return;
      }
      if (result == BankLinkOnboardingResult.incomplete) {
        AppToast.showInfo(context, AppStrings.bankLinkOnboardingIncompleteHint);
      } else if (result == BankLinkOnboardingResult.canceled) {
        AppToast.showError(context, AppStrings.bankLinkOnboardingCanceled);
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _linking = false);
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
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: AppStrings.selectBankAccountTitle,
              padding: EdgeInsets.fromLTRB(
                AppDimens.p16,
                AppDimens.v16,
                AppDimens.p16,
                0,
              ),
              leading: AppBackButton(
                onPressed: context.pop,
                color: AppColors.textPrimary,
              ),
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
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
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
                  onTap: _loading || _linking ? null : _addBankAccount,
                  loading: _linking,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
