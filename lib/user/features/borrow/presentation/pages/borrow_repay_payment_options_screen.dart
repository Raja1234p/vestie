import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/user/features/borrow/presentation/mappers/borrow_repay_confirm_route_args_mapper.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_loading_overlay.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_card_brand_icon.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_method_select_row.dart';
import 'package:vestie/user/features/borrow/domain/entities/borrow_repay_entities.dart';

import '../cubit/borrow_repay_payment_options_cubit.dart';

class BorrowRepayPaymentOptionsScreen extends StatelessWidget {
  final BorrowRepayPaymentOptionsRouteArgs args;

  const BorrowRepayPaymentOptionsScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BorrowRepayPaymentOptionsCubit, BorrowRepayPaymentOptionsState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage &&
          curr.errorMessage != null &&
          !curr.loadFailed,
      listener: (context, state) {
        AppToast.showError(context, state.errorMessage!);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: AppLoadingOverlay(
              isLoading: state.selecting,
              scrimColor: AppColors.postAuthLoadingOverlayScrim,
              child: Column(
                children: [
                  PostAuthFlowSubHeader(title: AppStrings.paymentMethodsTitle),
                  Expanded(
                    child: state.loading
                        ? const PaymentCardListShimmer()
                        : state.loadFailed
                        ? AppErrorView(
                            message: state.errorMessage,
                            onRetry: () => context
                                .read<BorrowRepayPaymentOptionsCubit>()
                                .load(),
                          )
                        : _OptionsBody(args: args, state: state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OptionsBody extends StatelessWidget {
  final BorrowRepayPaymentOptionsRouteArgs args;
  final BorrowRepayPaymentOptionsState state;

  const _OptionsBody({required this.args, required this.state});

  Future<void> _openPreview(
    BuildContext context,
    Future<BorrowRepayPreviewEntity?> Function() loadPreview,
    String paymentSourceType,
    String? paymentMethodId,
  ) async {
    final preview = await loadPreview();
    if (!context.mounted || preview == null) return;

    context.push(
      AppRoutes.borrowRepayConfirm,
      extra: BorrowRepayConfirmRouteArgsMapper.fromPreview(
        preview: preview,
        fallbackProjectName: args.projectName,
        paymentSourceType: paymentSourceType,
        paymentMethodId: paymentMethodId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = state.options;
    if (options == null) {
      return const SizedBox.shrink();
    }

    final cubit = context.read<BorrowRepayPaymentOptionsCubit>();
    final walletSelected =
        options.preferWallet && options.walletHasSufficientBalance;
    final preferredCardId = options.preferredCardId;

    return ListView(
      padding: FlowScreenFooterInsets.listPadding(context),
      children: [
        PaymentMethodSelectRow(
          selected: walletSelected,
          leading: SizedBox(
            width: 32.w,
            height: 32.h,
            child: SvgPicture.asset(
              AppAssets.iconDollarCircle,
              fit: BoxFit.contain,
            ),
          ),
          title: AppStrings.walletTitle,
          subtitle: AppFormatters.formatCurrency(options.walletAvailableBalance),
          enabled: options.walletHasSufficientBalance && !state.selecting,
          onTap: options.walletHasSufficientBalance && !state.selecting
              ? () => _openPreview(context, cubit.selectWallet, 'Wallet', null)
              : () {},
        ),
        if (!options.walletHasSufficientBalance) ...[
          SizedBox(height: 8.h),
          AppText(
            AppStrings.contributeWalletInsufficientSubtitle,
            style: GoogleFonts.lato(
              fontSize: 13.sp,
              color: AppColors.error,
            ),
          ),
        ],
        SizedBox(height: 16.h),
        ...options.cards.map(
          (card) => Padding(
            padding: EdgeInsets.only(bottom: AppDimens.paymentMethodRowGap),
            child: PaymentMethodSelectRow(
              selected: !walletSelected && preferredCardId == card.id,
              leading: SizedBox(
                width: 32.w,
                height: 32.h,
                child: PaymentCardBrandIcon(brand: card.brand),
              ),
              title: card.displayLabel,
              subtitle: card.last4.isNotEmpty ? '•••• ${card.last4}' : null,
              enabled: !state.selecting,
              onTap: state.selecting
                  ? () {}
                  : () => _openPreview(
                      context,
                      () => cubit.selectCard(card.id),
                      'Card',
                      card.id,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
