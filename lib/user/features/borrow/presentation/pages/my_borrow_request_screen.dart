import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import '../models/my_borrow_content_kind.dart';
import '../widgets/my_borrow_screen_shimmer.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';
import '../cubit/my_borrow_request_cubit.dart';
import '../navigation/borrow_repay_navigation.dart';
import '../widgets/cancel_borrow_request_dialog.dart';
import '../widgets/my_borrow_approved_body.dart';
import '../widgets/my_borrow_history_body.dart';
import '../widgets/my_borrow_request_active_body.dart';

/// Member My Borrow Request — empty, pending, and approved (My Borrow) states.
class MyBorrowRequestScreen extends StatelessWidget {
  final MyBorrowRequestRouteArgs args;

  const MyBorrowRequestScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyBorrowRequestCubit, MyBorrowRequestState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage &&
          curr.errorMessage != null &&
          !curr.loadFailed,
      listener: (context, state) {
        AppToast.showError(context, state.errorMessage!);
      },
      builder: (context, state) {
        final contentKind = resolveMyBorrowContentKind(state);
        final showsApproved = contentKind == MyBorrowContentKind.approved;
        final showsPending = contentKind == MyBorrowContentKind.pending;
        final headerTitle = showsApproved
            ? AppStrings.myBorrowTitle
            : AppStrings.myBorrowRequestTitle;

        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthFlowSubHeader(title: headerTitle),
                Expanded(
                  child: state.loading
                      ? MyBorrowScreenShimmer(kind: contentKind)
                      : state.loadFailed
                      ? AppErrorView(
                          message: state.errorMessage,
                          onRetry: () =>
                              context.read<MyBorrowRequestCubit>().load(),
                        )
                      : _buildScrollBody(
                          context,
                          state,
                          showsApproved,
                          showsPending,
                        ),
                ),
                if (state.loading)
                  FlowScreenFooter(child: const MyBorrowFooterShimmer())
                else if (!state.loadFailed)
                  FlowScreenFooter(
                    child: _buildPrimaryButton(
                      context,
                      state,
                      showsApproved,
                      showsPending,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollBody(
    BuildContext context,
    MyBorrowRequestState state,
    bool showsApproved,
    bool showsPending,
  ) {
    if (showsApproved) {
      final approved = state.repayableBorrowUi;
      if (approved == null) {
        return AppErrorView(
          message: state.errorMessage ?? AppStrings.errorGeneric,
          onRetry: () => context.read<MyBorrowRequestCubit>().load(),
        );
      }
      return SingleChildScrollView(
        padding: AppDimens.postAuthFlowScrollPadding,
        child: MyBorrowApprovedBody(data: approved),
      );
    }

    if (showsPending && state.activeRequest != null) {
      return SingleChildScrollView(
        padding: AppDimens.postAuthFlowScrollPadding,
        child: MyBorrowRequestActiveBody(
          activeRequest: state.activeRequest!,
          history: state.history,
        ),
      );
    }

    if (state.history.isNotEmpty) {
      return SingleChildScrollView(
        padding: AppDimens.postAuthFlowScrollPadding,
        child: MyBorrowHistoryBody(history: state.history),
      );
    }

    return const BorrowRequestsEmptyState(
      centered: true,
      subtitle: AppStrings.borrowRequestsEmptySubtitle,
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    MyBorrowRequestState state,
    bool showsApproved,
    bool showsPending,
  ) {
    if (showsApproved) {
      return AppButton(
        text: AppStrings.btnRepayBorrowAmount,
        isLoading: state.startingRepay,
        onPressed: state.startingRepay
            ? null
            : () => _onRepayPressed(context, state),
        useGradient: false,
        hasShadow: false,
        color: AppColors.purple700,
        borderRadius: 12.r,
      );
    }

    final makeRequestBlocked = args.borrowDisabledForViewer && !showsPending;

    return AppButton(
      text: showsPending
          ? AppStrings.btnCancelBorrowRequest
          : AppStrings.btnMakeBorrowRequest,
      isLoading: state.cancelling,
      onPressed: state.cancelling
          ? null
          : () => _onPrimaryAction(context, showsPending),
      useGradient: false,
      hasShadow: false,
      color: showsPending
          ? AppColors.red900
          : (makeRequestBlocked ? AppColors.grey800 : AppColors.grey1200),
      borderRadius: 12.r,
    );
  }

  Future<void> _onRepayPressed(
    BuildContext context,
    MyBorrowRequestState state,
  ) async {
    final cubit = context.read<MyBorrowRequestCubit>();
    try {
      final routeArgs = await cubit.prepareRepayFlow(
        projectName: args.projectName.isNotEmpty
            ? args.projectName
            : (state.repaySummary?.projectName ?? ''),
      );
      if (!context.mounted || routeArgs == null) return;

      await BorrowRepayNavigation.startRepayFlow(context, routeArgs);
    } finally {
      if (context.mounted) {
        cubit.clearStartingRepay();
      }
    }
  }

  Future<void> _onPrimaryAction(BuildContext context, bool showsPending) async {
    if (showsPending) {
      final cancelled = await showCancelBorrowRequestDialog(
        context,
        onConfirm: () =>
            context.read<MyBorrowRequestCubit>().cancelActiveRequest(),
      );
      if (!context.mounted || !cancelled) return;
      context.pop(true);
      return;
    }

    if (args.borrowDisabledForViewer) {
      AppToast.showInfo(context, AppStrings.borrowRequiresCoLeaderMessage);
      return;
    }

    final submitted = await context.push<bool>(
      AppRoutes.borrowFlow,
      extra: args.walletFlowArgs,
    );
    if (!context.mounted || submitted != true) return;
    await context.read<MyBorrowRequestCubit>().load();
  }
}
