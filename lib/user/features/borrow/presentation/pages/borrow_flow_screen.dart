import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_stacked_currency_field.dart';
import 'package:vestie/core/widgets/common/app_tick_switch.dart';
import 'package:vestie/core/widgets/common/app_success_screen.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import '../cubit/borrow_cubit.dart';

class BorrowFlowScreen extends StatelessWidget {
  const BorrowFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BorrowCubit, BorrowState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage &&
          curr.errorMessage != null &&
          curr.step != BorrowStep.confirm,
      listener: (context, state) {
        AppToast.showError(context, state.errorMessage!);
      },
      child: BlocBuilder<BorrowCubit, BorrowState>(
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
      ),
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
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<BorrowCubit>().state;
    _amountDigitsController = TextEditingController(
      text: cubitState.amountDigits,
    );
    _noteController = TextEditingController(text: cubitState.note);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _amountFieldFocus.requestFocus();
    });
    _noteFocus.addListener(_onNoteFocusChanged);
    _amountFieldFocus.addListener(_onAmountFocusChanged);
  }

  void _onAmountFocusChanged() {
    if (!_amountFieldFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _onNoteFocusChanged() {
    if (!_noteFocus.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _noteFocus.removeListener(_onNoteFocusChanged);
    _amountFieldFocus.removeListener(_onAmountFocusChanged);
    _noteFocus.dispose();
    _amountFieldFocus.dispose();
    _amountDigitsController.dispose();
    _noteController.dispose();
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

  void _syncNoteFromState(String note) {
    if (!_noteFocus.hasFocus && _noteController.text != note) {
      _noteController.value = TextEditingValue(
        text: note,
        selection: TextSelection.collapsed(offset: note.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BorrowCubit, BorrowState>(
      builder: (context, state) {
        final c = context.read<BorrowCubit>();
        _syncAmountFieldFromState(state.amountDigits);
        _syncNoteFromState(state.note);
        final over = state.amountValue > state.args.borrowLimit;
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthFlowSubHeader(
                  title: AppStrings.borrowScreenTitle,
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
                                      : state.displayDollar,
                                  controller: _amountDigitsController,
                                  focusNode: _amountFieldFocus,
                                  onDigitsChanged: c.setAmountDigits,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.searchBarBg,
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                                child: AppText(
                                  '${AppStrings.labelBorrowLimitChip}: '
                                  '\$${state.borrowLimitFormatted} '
                                  '${AppStrings.borrowLimitSetByLeaderSuffix}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.neutral1200,
                                  ),
                                ),
                              ),
                              SizedBox(height: 42.h),
                              TextField(
                                controller: _noteController,
                                focusNode: _noteFocus,
                                onChanged: c.setNote,
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: GoogleFonts.lato(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.inputFieldText,
                                ),
                                decoration: InputDecoration(
                                  hintText: AppStrings.labelNote,
                                  hintStyle: GoogleFonts.lato(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.authHint,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.searchBarBg,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: const BorderSide(
                                      color: AppColors.searchBarBg,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: const BorderSide(
                                      color: AppColors.searchBarBg,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: const BorderSide(
                                      color: AppColors.searchBarBg,
                                    ),
                                  ),
                                ),
                              ),
                              if (over) ...[
                                SizedBox(height: 8.h),
                                AppText(
                                  AppStrings.borrowAmountExceedsLimit,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 12.sp,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
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
                    isLoading: state.loading,
                    onPressed: (state.amountValue <= 0 || over || state.loading)
                        ? null
                        : c.toConfirm,
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

class _BorrowConfirmView extends StatelessWidget {
  const _BorrowConfirmView({required this.state});
  final BorrowState state;

  @override
  Widget build(BuildContext context) {
    final c = context.read<BorrowCubit>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.borrowTermsTitle,
              onBack: c.backToAmount,
            ),
            Expanded(
              child: ListView(
                padding: AppDimens.postAuthFlowScrollPadding,
                children: [
                  _label(AppStrings.sectionBorrowAmount),
                  SizedBox(height: 12.h),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _row(AppStrings.labelAmount, state.displayDollar),
                        _row(
                          AppStrings.labelFullAmountDueBy,
                          state.dueByLabel,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _label(AppStrings.sectionPenalty),
                  SizedBox(height: 12.h),
                  _card(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _row(
                          AppStrings.labelPenaltyIfMissed,
                          state.penaltyIfMissedLabel,
                        ),
                        _row(
                          AppStrings.labelPenaltyApplies,
                          state.penaltyAppliesLabel,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppTickSwitch(
                        value: state.termsAccepted,
                        onChanged: (v) => c.setTermsAccepted(v),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: AppText(
                          state.agreementText,
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
                  if (state.errorMessage != null &&
                      state.errorMessage!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    AppText(
                      state.errorMessage!,
                      style: GoogleFonts.lato(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red900,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    AppText(
                      AppStrings.borrowSubmitRetryHint,
                      style: GoogleFonts.lato(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            FlowScreenFooter(
              child: AppButton(
                text: AppStrings.btnSubmitBorrowRequest,
                isLoading: state.loading,
                onPressed: !state.termsAccepted || state.loading
                    ? null
                    : c.submit,
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
                color: AppColors.neutral700,
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
}

class _BorrowSuccessView extends StatelessWidget {
  const _BorrowSuccessView({required this.state});
  final BorrowState state;

  @override
  Widget build(BuildContext context) {
    return AppSuccessScreen(
      title: AppStrings.borrowRequestSubmitted,
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
              const TextSpan(text: AppStrings.borrowSuccessSubtitlePrefix),
              TextSpan(
                text: state.displayDollar,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: AppStrings.borrowSuccessSubtitleSuffix),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      buttonText: AppStrings.btnBackToProject,
      onButtonPressed: () => context.pop(true),
    );
  }
}
