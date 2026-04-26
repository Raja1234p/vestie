import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_back_button.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_purple_dashed_line.dart';
import '../../../../core/widgets/common/app_stacked_currency_field.dart';
import '../../../../core/widgets/common/app_success_screen.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../../../core/widgets/common/app_tick_switch.dart';
import '../../../../core/widgets/common/app_wallet_pill.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../cubit/contribute_cubit.dart';

class ContributeFlowScreen extends StatelessWidget {
  const ContributeFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeCubit, ContributeState>(
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
    );
  }
}

class _ContributeAmountView extends StatefulWidget {
  const _ContributeAmountView();

  @override
  State<_ContributeAmountView> createState() => _ContributeAmountViewState();
}

class _ContributeAmountViewState extends State<_ContributeAmountView> {
  final FocusNode _amountFocus = FocusNode();
  late final TextEditingController _amountDigitsController;

  @override
  void initState() {
    super.initState();
    _amountDigitsController = TextEditingController();
    _amountFocus.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _amountDigitsController.text =
          context.read<ContributeCubit>().state.amountDigits;
    });
  }

  @override
  void dispose() {
    _amountFocus.dispose();
    _amountDigitsController.dispose();
    super.dispose();
  }

  void _syncAmountField(ContributeState state) {
    if (!_amountFocus.hasFocus &&
        _amountDigitsController.text != state.amountDigits) {
      _amountDigitsController.value = TextEditingValue(
        text: state.amountDigits,
        selection: TextSelection.collapsed(offset: state.amountDigits.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContributeCubit, ContributeState>(
      builder: (context, state) {
        final c = context.read<ContributeCubit>();
        _syncAmountField(state);
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthHeader(
                  title: AppStrings.contributeScreenTitle,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  leading: AppBackButton(
                    onPressed: () => context.pop(),
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 8.h + bottomInset),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                AppStrings.addAmount,
                                style: GoogleFonts.lato(
                                  fontSize: 14.sp,
                                  color: AppColors.textBody,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              AppStackedCurrencyField(
                                displayDollar: state.amountDigits.isEmpty
                                    ? r'$0.00'
                                    : state.displayAmountDollar,
                                controller: _amountDigitsController,
                                focusNode: _amountFocus,
                                onDigitsChanged: c.setAmountDigits,
                              ),
                              SizedBox(height: 20.h),
                              AppWalletPill(
                                formattedBalance: state.args.walletAmountFormatted,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AppButton(
                    text: AppStrings.btnConfirm,
                    onPressed: state.amountValue <= 0 ? null : c.toConfirm,
                  ),
                ),
                SizedBox(height: 12.h),
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
    final c = context.read<ContributeCubit>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostAuthHeader(
              title: AppStrings.contributeConfirmHeader,
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              leading: AppBackButton(
                onPressed: c.backToAmount,
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                children: [
                  SizedBox(height: 6.h),
                  _sectionLabel(AppStrings.labelPaymentMethod),
                  SizedBox(height: 8.h),
                  _borderCard(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            AppStrings.labelPaymentFrom,
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              color: AppColors.textBody,
                            ),
                          ),
                          AppWalletPill(
                            formattedBalance: state.args.walletAmountFormatted,
                            onTap: () {},
                            backgroundColor: AppColors.cardBg,
                            borderColor: AppColors.cardBorder,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _sectionLabel(AppStrings.labelBreakdown),
                  SizedBox(height: 8.h),
                  _borderCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _paddedRow(
                          AppStrings.labelContributionAmount,
                          state.displayAmountDollar,
                        ),
                        const AppPurpleDashedLine(),
                        _paddedRow(
                          AppStrings.labelVestieFee3,
                          '-\$${state.vestieFeeFormatted}',
                        ),
                        const AppPurpleDashedLine(),
                        _paddedRow(
                          AppStrings.labelTotalDeduction,
                          '\$${state.totalDeductionFormatted}',
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppTickSwitch(
                        value: state.nonRefundableAccepted,
                        onChanged: (v) => c.setNonRefundable(v),
                      ),
                      SizedBox(width: 6.w),
                      SizedBox(width: 4.w),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: AppText(
                          AppStrings.contributeNonRefundable,
                          style: GoogleFonts.lato(
                            fontSize: 13.sp,
                            color: AppColors.textBody,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
              child: AppButton(
                text: AppStrings.btnConfirm,
                onPressed: !state.nonRefundableAccepted
                    ? null
                    : c.toSuccess,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) {
    return AppText(
      t,
      style: GoogleFonts.lato(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral1100,
      ),
    );
  }

  Widget _borderCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: child,
    );
  }

  Widget _paddedRow(String left, String right, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            left,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.grey1100,
            ),
          ),
          AppText(
            right,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.grey1100,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributeSuccessView extends StatelessWidget {
  const _ContributeSuccessView({required this.state});
  final ContributeState state;

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      backgroundImagePath: AppAssets.contributionSuccessBg,
      svgAssetPath: AppAssets.projectCreatedImage,
      title: AppStrings.contributionSuccessTitle,
      subtitleWidget: AppText(
        '\$${state.amountFormatted} added to ${state.args.projectName}',
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          fontSize: 18.sp,
          color: AppColors.textBody,
        ),
      ),
      buttonText: AppStrings.btnDone,
      onButtonPressed: () => context.pop(),
    );
  }
}
