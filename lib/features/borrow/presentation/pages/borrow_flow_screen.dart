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
import '../../../../core/widgets/common/app_stacked_currency_field.dart';
import '../../../../core/widgets/common/app_tick_switch.dart';
import '../../../../core/widgets/common/app_purple_dashed_line.dart';
import '../../../../core/widgets/common/app_success_screen.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';
import '../cubit/borrow_cubit.dart';

class BorrowFlowScreen extends StatelessWidget {
  const BorrowFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BorrowCubit, BorrowState>(
      builder: (context, s) {
        switch (s.step) {
          case BorrowStep.amount:
            return const _BorrowAmountView();
          case BorrowStep.confirm:
            return _BorrowConfirmView(state: s);
          case BorrowStep.success:
            return _BorrowSuccessView(state: s);
        }
      },
    );
  }
}

class _BorrowAmountView extends StatefulWidget {
  const _BorrowAmountView();

  @override
  State<_BorrowAmountView> createState() => _BorrowAmountViewState();
}

class _BorrowAmountViewState extends State<_BorrowAmountView> {
  final FocusNode _noteFocus = FocusNode();
  final FocusNode _amountFieldFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _amountDigitsController;

  @override
  void initState() {
    super.initState();
    _amountDigitsController = TextEditingController();
    _noteFocus.addListener(_onNoteFocus);
    _amountFieldFocus.addListener(_onAnyFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final digits = context.read<BorrowCubit>().state.amountDigits;
      if (_amountDigitsController.text != digits) {
        _amountDigitsController.text = digits;
      }
    });
  }

  void _onNoteFocus() {
    if (mounted) setState(() {});
  }

  void _onAnyFocus() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _noteFocus.removeListener(_onNoteFocus);
    _amountFieldFocus.removeListener(_onAnyFocus);
    _noteFocus.dispose();
    _amountFieldFocus.dispose();
    _amountDigitsController.dispose();
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BorrowCubit, BorrowState>(
      builder: (context, state) {
        final c = context.read<BorrowCubit>();
        _syncAmountFieldFromState(state.amountDigits);
        final over = state.amountValue > state.args.borrowLimit;
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthHeader(
                  title: AppStrings.borrowScreenTitle,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  leading: AppBackButton(
                    onPressed: () => context.pop(),
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h + bottomInset),
                    child: Column(
                      children: [
                        AppStackedCurrencyField(
                          displayDollar: state.amountDigits.isEmpty
                              ? r'$0.00'
                              : state.displayDollar,
                          controller: _amountDigitsController,
                          focusNode: _amountFieldFocus,
                          onDigitsChanged: c.setAmountDigits,
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.searchBarBg,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: AppText(
                            '${AppStrings.labelBorrowLimitChip}: '
                            '\$${state.borrowLimitFormatted} '
                            '(set by leader)',
                            style: GoogleFonts.lato(
                              fontSize: 13.sp,
                              color: AppColors.grey800,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            AppStrings.labelNote,
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey1100,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          focusNode: _noteFocus,
                          onChanged: c.setNote,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: AppStrings.hintBorrowNote,
                            filled: true,
                            fillColor: AppColors.searchBarBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: AppColors.cardBorder,
                              ),
                            ),
                          ),
                        ),
                        if (over) ...[
                          SizedBox(height: 8.h),
                          AppText(
                            AppStrings.borrowAmountExceedsLimit,
                            style: GoogleFonts.lato(
                              fontSize: 12.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AppButton(
                    text: AppStrings.btnConfirm,
                    onPressed: (state.amountValue <= 0 || over)
                        ? null
                        : c.toConfirm,
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

class _BorrowConfirmView extends StatelessWidget {
  const _BorrowConfirmView({required this.state});
  final BorrowState state;

  @override
  Widget build(BuildContext context) {
    final c = context.read<BorrowCubit>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostAuthHeader(
              title: AppStrings.borrowTermsTitle,
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
                  _label(AppStrings.sectionBorrowAmount),
                  SizedBox(height: 8.h),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _row('${AppStrings.labelAmount}:', state.displayDollar),
                        const AppPurpleDashedLine(),
                        _row(
                          AppStrings.labelFullAmountDueBy,
                          state.args.borrowDueByLabel,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _label(AppStrings.sectionPenalty),
                  SizedBox(height: 8.h),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _row(
                          AppStrings.labelPenaltyIfMissed,
                          AppStrings.penaltyValuePercent,
                        ),
                        const AppPurpleDashedLine(),
                        _row(
                          AppStrings.labelPenaltyApplies,
                          AppStrings.penaltyValueOneTime,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppTickSwitch(
                        value: state.termsAccepted,
                        onChanged: (v) => c.setTermsAccepted(v),
                      ),
                      SizedBox(width: 6.w),
                      SizedBox(width: 4.w),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.lato(
                              fontSize: 13.sp,
                              color: AppColors.textBody,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to repay '),
                              TextSpan(
                                text: state.displayDollar,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text:
                                    ' in full by ${state.args.borrowDueByLabel}.',
                              ),
                            ],
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
                text: AppStrings.btnSubmitBorrowRequest,
                onPressed:
                    !state.termsAccepted ? null : c.submit,
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
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: child,
    );
  }

  Widget _row(String left, String right) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppText(
              left,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: AppColors.grey800,
              ),
            ),
          ),
          AppText(
            right,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.grey1100,
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowSuccessView extends StatelessWidget {
  const _BorrowSuccessView({required this.state});
  final BorrowState state;

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      backgroundImagePath: AppAssets.contributionSuccessBg,
      svgAssetPath: AppAssets.projectCreatedImage,
      title: AppStrings.borrowRequestSubmitted,
      subtitleWidget: Text.rich(
        TextSpan(
          style: GoogleFonts.lato(
            fontSize: 18.sp,
            color: AppColors.textBody,
            height: 1.35,
          ),
          children: [
            const TextSpan(text: 'Your '),
            TextSpan(
              text: state.displayDollar,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(
              text:
                  ' borrow request has been sent to the group for voting and leader review.',
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      buttonText: AppStrings.btnBackToProject,
      onButtonPressed: () => context.pop(),
    );
  }
}
