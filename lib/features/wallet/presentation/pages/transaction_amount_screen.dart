import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/app_dimens.dart' show AppDimens, AppRadius;
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_numpad.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_stacked_currency_field.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_selection.dart';
import '../../domain/wallet_transaction_type.dart';
import '../cubit/wallet_transaction_cubit.dart';

class TransactionAmountScreen extends StatefulWidget {
  const TransactionAmountScreen({super.key});

  @override
  State<TransactionAmountScreen> createState() =>
      _TransactionAmountScreenState();
}

class _TransactionAmountScreenState extends State<TransactionAmountScreen> {
  final FocusNode _amountFieldFocus = FocusNode();
  late final TextEditingController _amountDigitsController;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<WalletTransactionCubit>().state;
    _amountDigitsController =
        TextEditingController(text: cubitState.amountDigits);
    if (cubitState.transactionType == WalletTransactionType.deposit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _amountFieldFocus.requestFocus();
      });
    }
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

  void _onContinueDeposit(BuildContext context, WalletTransactionCubit cubit) {
    context.push(AppRoutes.selectPaymentMethod).then((result) {
      if (!context.mounted || result == null) return;
      switch (result) {
        case CardPaymentMethodSelection(:final card):
          cubit.selectCard(card);
        case WalletPaymentMethodSelection():
          cubit.selectWallet();
      }
      context.push(AppRoutes.transactionConfirmation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletTransactionCubit, WalletTransactionState>(
      builder: (context, state) {
        final cubit = context.read<WalletTransactionCubit>();
        final isDeposit =
            state.transactionType == WalletTransactionType.deposit;
        final title =
            isDeposit ? AppStrings.depositFundsTitle : AppStrings.withdrawFundsTitle;
        final subtitle = isDeposit
            ? AppStrings.depositAmountSubtitle
            : AppStrings.withdrawAmountSubtitle;

        if (isDeposit) {
          _syncAmountFieldFromState(state.amountDigits);
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
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
                  child: isDeposit
                      ? _DepositAmountBody(
                          subtitle: subtitle,
                          displayDollar: state.amountDigits.isEmpty
                              ? AppFormatters.formatCurrency(0)
                              : state.formattedAmount,
                          amountController: _amountDigitsController,
                          amountFocus: _amountFieldFocus,
                          onDigitsChanged: cubit.setAmountDigits,
                        )
                      : _WithdrawAmountBody(
                          subtitle: subtitle,
                          displayAmount: state.amountDigits.isEmpty
                              ? AppFormatters.formatCurrency(0)
                              : state.formattedAmount,
                          onContinue: state.amountDigits.isEmpty
                              ? null
                              : () {
                                  cubit.prepareWithdrawMethodSelection();
                                  context.push(AppRoutes.withdrawMethod);
                                },
                        ),
                ),
                if (isDeposit)
                  FlowScreenFooter(
                    child: AppButton(
                      text: AppStrings.btnContinue,
                      onPressed: state.amountDigits.isEmpty
                          ? null
                          : () => _onContinueDeposit(context, cubit),
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.r16),
                    ),
                    child: AppNumpad(
                      onDigit: cubit.appendAmountDigit,
                      onBackspace: cubit.removeAmountDigit,
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

class _DepositAmountBody extends StatelessWidget {
  const _DepositAmountBody({
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
    return Column(
      children: [
        const Spacer(),
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
        const Spacer(),
      ],
    );
  }
}

class _WithdrawAmountBody extends StatelessWidget {
  const _WithdrawAmountBody({
    required this.subtitle,
    required this.displayAmount,
    required this.onContinue,
  });

  final String subtitle;
  final String displayAmount;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
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
        AppText(
          displayAmount,
          style: GoogleFonts.lato(
            fontSize: 50.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.grey1100,
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.p24),
          child: AppButton(
            text: AppStrings.btnContinue,
            onPressed: onContinue,
          ),
        ),
        SizedBox(height: AppDimens.v12),
      ],
    );
  }
}
