import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_payment_method_pill.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_selection.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_stacked_currency_field.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/core/widgets/common/app_tick_switch.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import '../../../contributions/presentation/bloc/contribute_bloc.dart';
import '../../../contributions/presentation/bloc/contribute_event.dart';
import '../../../contributions/presentation/bloc/contribute_state.dart';
import '../navigation/contribute_payment_navigation.dart';

class ContributeFlowScreen extends StatelessWidget {
  const ContributeFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContributeBloc, ContributeState>(
      listenWhen: (p, c) =>
          p.submitFailure != c.submitFailure ||
          p.previewFailure != c.previewFailure,
      listener: (context, state) {
        final msg =
            state.submitFailure?.message ?? state.previewFailure?.message;
        if (msg != null && msg.isNotEmpty) {
          AppToast.showError(context, msg);
        }
      },
      child: BlocBuilder<ContributeBloc, ContributeState>(
        builder: (context, s) {
          switch (s.step) {
            case ContributeStep.amount:
              return const _ContributeAmountView();
            case ContributeStep.confirm:
              return _ContributeConfirmView(state: s);
            case ContributeStep.success:
              return _ContributeSuccessView(state: s);
          }
        },
      ),
    );
  }
}

class _ContributeAmountView extends StatefulWidget {
  const _ContributeAmountView();

  @override
  State<_ContributeAmountView> createState() => _ContributeAmountViewState();
}

class _ContributeAmountViewState extends State<_ContributeAmountView> {
  final FocusNode _amountFieldFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _amountDigitsController;

  @override
  void initState() {
    super.initState();
    _amountDigitsController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final digits = context.read<ContributeBloc>().state.amountDigits;
      if (_amountDigitsController.text != digits) {
        _amountDigitsController.text = digits;
      }
      _amountFieldFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountFieldFocus.dispose();
    _amountDigitsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncAmountFieldFromState(String digits) {
    if (!_amountFieldFocus.hasFocus && _amountDigitsController.text != digits) {
      _amountDigitsController.value = TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeBloc, ContributeState>(
      builder: (context, state) {
        final bloc = context.read<ContributeBloc>();
        _syncAmountFieldFromState(state.amountDigits);
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthFlowSubHeader(
                  title: AppStrings.contributeScreenTitle,
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _amountFieldFocus.requestFocus(),
                                behavior: HitTestBehavior.opaque,
                                child: AppStackedCurrencyField(
                                  displayDollar: state.amountDigits.isEmpty
                                      ? r'$0.00'
                                      : state.displayAmountDollar,
                                  controller: _amountDigitsController,
                                  focusNode: _amountFieldFocus,
                                  onDigitsChanged: (raw) =>
                                      bloc.add(DigitsChangedEvent(digits: raw)),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _ContributePaymentPill(
                                state: state,
                                forConfirm: false,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                FlowScreenFooter(
                  child: AppButton(
                    text: AppStrings.btnConfirm,
                    isLoading: state.isPreviewLoading,
                    onPressed: !state.canProceedFromAmount || state.isPreviewLoading
                        ? null
                        : () => bloc.add(GoToConfirmEvent()),
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

class _ContributeConfirmView extends StatelessWidget {
  const _ContributeConfirmView({required this.state});
  final ContributeState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ContributeBloc>();
    final args = state.args;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.contributeConfirmHeader,
              onBack: () => bloc.add(BackToAmountEvent()),
            ),
            Expanded(
              child: ListView(
                padding: AppDimens.postAuthFlowScrollPadding,
                children: [
                  _label(AppStrings.labelPaymentMethod),
                  SizedBox(height: 12.h),
                  _card(
                    _paymentRow(
                      '${AppStrings.labelPaymentFrom}:',
                      _ContributePaymentPill(
                        state: state,
                        forConfirm: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _label(AppStrings.labelBreakdown),
                  SizedBox(height: 12.h),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 22.h),
                        _row(
                          '${AppStrings.labelContributionAmount}:',
                          state.displayAmountDollar,
                        ),
                        SizedBox(height: 12.h),
                        _row(
                          AppStrings.labelVestieFee3,
                          '-\$${state.vestieFeeFormatted}',
                        ),
                        SizedBox(height: 24.h),
                        const _BreakdownDivider(),
                        SizedBox(height: 24.h),
                        _row(
                          AppStrings.labelTotalDeduction,
                          '\$${state.totalDeductionFormatted}',
                          color: AppColors.projectDetailText,
                        ),
                        SizedBox(height: 12.h),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppTickSwitch(
                        value: state.nonRefundableAccepted,
                        onChanged: (v) =>
                            bloc.add(SetNonRefundableEvent(accepted: v)),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: AppText(
                          AppStrings.contributeNonRefundable,
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.neutral700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FlowScreenFooter(
              child: AppButton(
                text: AppStrings.btnConfirm,
                isLoading: state.isSubmitLoading,
                onPressed: !state.canTapConfirm
                    ? null
                    : () => bloc.add(
                          ConfirmSubmitEvent(
                            projectId: args?.projectId ?? '',
                            amount: state.amountValue,
                            walletId: state.selectedWalletId,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) {
    return AppText(
      t,
      style: GoogleFonts.lato(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.grey1100,
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.neutral400),
      ),
      child: child,
    );
  }

  Widget _row(String left, String right, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppText(
              left,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: color ?? AppColors.neutral700,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          AppText(
            right,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral1200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(String left, Widget trailing) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AppText(
              left,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: AppColors.neutral700,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _BreakdownDivider extends StatelessWidget {
  const _BreakdownDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.neutral400);
  }
}

Future<void> _openContributePaymentPicker(
  BuildContext context,
  ContributeBloc bloc,
  ContributeState state,
) async {
  final result = await ContributePaymentNavigation.openPicker(
    context,
    state: state,
  );
  if (!context.mounted || result == null) return;
  switch (result) {
    case CardPaymentMethodSelection(:final card):
      bloc.add(
        ContributePaymentMethodSelectedEvent(
          card: card,
          payFromWallet: false,
        ),
      );
    case WalletPaymentMethodSelection():
      bloc.add(
        const ContributePaymentMethodSelectedEvent(payFromWallet: true),
      );
  }
}

class _ContributePaymentPill extends StatelessWidget {
  const _ContributePaymentPill({required this.state, required this.forConfirm});

  final ContributeState state;
  final bool forConfirm;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ContributeBloc>();
    final walletFormatted = state.args?.walletAmountFormatted ?? '0';
    final canPick = forConfirm
        ? state.canChangePaymentMethod
        : state.canPickPaymentMethodOnAmount;

    final hasError = forConfirm && state.hasPaymentValidationError;

    if (!state.payFromWallet && state.selectedCard != null) {
      return AppPaymentMethodPill.card(
        card: state.selectedCard!,
        showChevron: canPick,
        hasError: hasError,
        onTap: canPick
            ? () => _openContributePaymentPicker(context, bloc, state)
            : null,
      );
    }

    if (forConfirm && !state.payFromWallet && state.selectedCard == null) {
      return AppPaymentMethodPill.placeholder(
        placeholderLabel: AppStrings.labelSelectPaymentCard,
        showChevron: canPick,
        hasError: hasError,
        onTap: canPick
            ? () => _openContributePaymentPicker(context, bloc, state)
            : null,
      );
    }

    return AppPaymentMethodPill.wallet(
      formattedBalance: walletFormatted,
      showChevron: canPick,
      hasError: hasError,
      onTap: canPick
          ? () => _openContributePaymentPicker(context, bloc, state)
          : null,
    );
  }
}

class _ContributeSuccessView extends StatelessWidget {
  const _ContributeSuccessView({required this.state});
  final ContributeState state;

  @override
  Widget build(BuildContext context) {
    final projectName = state.args?.projectName ?? '';
    return AppSuccessScreen(
      title: AppStrings.contributionSuccessTitle,
      subtitleWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textBody,
              height: 1.35,
            ),
            children: [
              const TextSpan(text: 'Your '),
              TextSpan(
                text: state.displayAmountDollar,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' contribution has been added to $projectName.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      buttonText: AppStrings.btnBackToProject,
      onButtonPressed: () => context.pop(state.submitResult),
    );
  }
}
