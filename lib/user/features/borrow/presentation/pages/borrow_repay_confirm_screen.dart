import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';

import '../cubit/borrow_repay_confirm_cubit.dart';
import '../widgets/borrow_repay_confirm_section.dart';

/// Borrow repay confirm — after payment method selection (Figma).
class BorrowRepayConfirmScreen extends StatelessWidget {
  final BorrowRepayConfirmRouteArgs args;

  const BorrowRepayConfirmScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BorrowRepayConfirmCubit, BorrowRepayConfirmState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null && message.isNotEmpty) {
          AppToast.showError(context, message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                PostAuthFlowSubHeader(title: AppStrings.repayScreenTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppDimens.postAuthFlowScrollPadding,
                    child: BorrowRepayConfirmSection(args: args),
                  ),
                ),
                FlowScreenFooter(
                  child: AppButton(
                    text: AppStrings.btnConfirmRepay,
                    isLoading: state.submitting,
                    onPressed: state.submitting
                        ? null
                        : () => _onConfirm(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onConfirm(BuildContext context) async {
    final result = await context.read<BorrowRepayConfirmCubit>().submit();
    if (!context.mounted || result == null) return;

    context.pushReplacement(
      AppRoutes.borrowRepaySuccess,
      extra: BorrowRepayConfirmRouteArgs(
        projectId: args.projectId,
        projectName: args.projectName,
        borrowRequestId: args.borrowRequestId,
        repayAmount: args.repayAmount,
        totalRepayment: result.totalRepaid,
        dueDateLabel: args.dueDateLabel,
        paymentMethodLabel: args.paymentMethodLabel,
        paymentSourceType: args.paymentSourceType,
        paymentMethodId: args.paymentMethodId,
        penaltyPercent: args.penaltyPercent,
        penaltyAmount: args.penaltyAmount,
        successMessage: result.message,
      ),
    );
  }
}
