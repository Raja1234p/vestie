import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart' show AppDimens;
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_stacked_currency_field.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/core/utils/app_snackbar.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/services/bank_accounts_prefetch.dart';
import 'package:vestie/core/services/payment_methods_prefetch.dart';
import 'package:vestie/core/utils/wallet_withdraw_validation.dart';
import 'package:vestie/features/payment_methods/domain/payment_methods_cache.dart';

import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_transaction_cubit.dart';
import '../navigation/wallet_deposit_navigation.dart';

class TransactionAmountScreen extends StatefulWidget {
  const TransactionAmountScreen({super.key});

  @override
  State<TransactionAmountScreen> createState() =>
      _TransactionAmountScreenState();
}

class _TransactionAmountScreenState extends State<TransactionAmountScreen> {
  final FocusNode _amountFieldFocus = FocusNode();
  late final TextEditingController _amountDigitsController;
  bool _resolvingPaymentMethods = false;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<WalletTransactionCubit>().state;
    _amountDigitsController =
        TextEditingController(text: cubitState.amountDigits);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _amountFieldFocus.requestFocus();
      _warmCachesForFlow();
    });
  }

  void _warmCachesForFlow() {
    final type = context.read<WalletTransactionCubit>().state.transactionType;
    if (type == WalletTransactionType.withdraw) {
      ServiceLocator.instance.getWalletUseCase(forceRefresh: false);
      unawaited(BankAccountsPrefetch.warmIfNeeded());
      return;
    }
    unawaited(PaymentMethodsPrefetch.warmIfNeeded());
  }

  @override
  void dispose() {
    _amountFieldFocus.dispose();
    _amountDigitsController.dispose();
    super.dispose();
  }

  void _syncAmountFieldFromState(String digits) {
    if (!_amountFieldFocus.hasFocus &&
        _amountDigitsController.text != digits) {
      _amountDigitsController.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
  }

  Future<void> _onContinueDeposit(
    BuildContext context,
    WalletTransactionCubit cubit,
  ) async {
    if (PaymentMethodsCache.value != null) {
      WalletDepositNavigation.continueFromAmount(context, cubit);
      return;
    }

    setState(() => _resolvingPaymentMethods = true);
    await PaymentMethodsPrefetch.warmIfNeeded();
    if (!mounted) return;
    setState(() => _resolvingPaymentMethods = false);

    if (!context.mounted) return;
    WalletDepositNavigation.continueFromAmount(context, cubit);
  }

  void _onContinueWithdraw(BuildContext context, WalletTransactionCubit cubit) {
    final err =
        WalletWithdrawValidation.validateForWithdraw(cubit.state.amountParsed);
    if (err != null) {
      AppSnackBar.showError(context, err);
      return;
    }
    cubit.prepareWithdrawMethodSelection();
    context.push(AppRoutes.withdrawMethod);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final cubit = context.read<WalletTransactionCubit>();
        final isDeposit =
            state.transactionType == WalletTransactionType.deposit;
        final title = isDeposit
            ? AppStrings.depositFundsTitle
            : AppStrings.withdrawFundsTitle;
        final subtitle = isDeposit
            ? AppStrings.depositAmountSubtitle
            : AppStrings.withdrawAmountSubtitle;

        _syncAmountFieldFromState(state.amountDigits);

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthHeader(
                  title: title,
                  padding: EdgeInsets.fromLTRB(
                    AppDimens.p16,
                    AppDimens.v16,
                    AppDimens.p16,
                    AppDimens.v10,
                  ),
                  leading: AppBackButton(
                    onPressed: () {
                      cubit.reset();
                      context.pop();
                    },
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: _AmountEntryBody(
                    subtitle: subtitle,
                    displayDollar: state.amountDigits.isEmpty
                        ? AppFormatters.formatCurrency(0)
                        : state.formattedAmount,
                    amountController: _amountDigitsController,
                    amountFocus: _amountFieldFocus,
                    onDigitsChanged: cubit.setAmountDigits,
                  ),
                ),
                FlowScreenFooter(
                  child: AppButton(
                    text: AppStrings.btnContinue,
                    isLoading: isDeposit && _resolvingPaymentMethods,
                    onPressed: state.amountDigits.isEmpty ||
                            (isDeposit && _resolvingPaymentMethods)
                        ? null
                        : () => isDeposit
                            ? _onContinueDeposit(context, cubit)
                            : _onContinueWithdraw(context, cubit),
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

class _AmountEntryBody extends StatelessWidget {
  const _AmountEntryBody({
    required this.subtitle,
    required this.displayDollar,
    required this.amountController,
    required this.amountFocus,
    required this.onDigitsChanged,
  });

  final String subtitle;
  final String displayDollar;
  final TextEditingController amountController;
  final FocusNode amountFocus;
  final ValueChanged<String> onDigitsChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: AppDimens.p24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
                  ),
                ),
                SizedBox(height: AppDimens.v10),
                AppStackedCurrencyField(
                  displayDollar: displayDollar,
                  controller: amountController,
                  focusNode: amountFocus,
                  onDigitsChanged: onDigitsChanged,
                  amountFontSize: 50.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
