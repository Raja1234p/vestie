import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/models/bank_link_onboarding_result.dart';
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

  Future<void> _addBankAccount() async {
    final result = await context.push<BankLinkOnboardingResult>(
      AppRoutes.bankLinkOnboarding,
    );
    if (!mounted || result == null) return;
    switch (result) {
      case BankLinkOnboardingResult.linked:
        await _load();
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
                AppDimens.v10,
              ),
              leading: AppBackButton(
                onPressed: context.pop,
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _loading
                  ? const BankAccountListShimmer()
                  : isEmpty
                      ? _EmptyBankState(error: _error)
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          itemCount: _banks.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final bank = _banks[index];
                            return Material(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(12.r),
                              child: InkWell(
                                onTap: () => _onSelect(bank),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AppText(
                                          bank.displayName,
                                          style: GoogleFonts.lato(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.neutral1200,
                                          ),
                                        ),
                                      ),
                                      if (bank.isDefault)
                                        AppText(
                                          AppStrings.bankAccountDefaultLabel,
                                          style: GoogleFonts.lato(
                                            fontSize: 12.sp,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
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

class _EmptyBankState extends StatelessWidget {
  const _EmptyBankState({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              error ?? AppStrings.bankLinkEmptySubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                color: AppColors.neutral700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
