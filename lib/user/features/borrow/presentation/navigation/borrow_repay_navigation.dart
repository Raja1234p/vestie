import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/borrow_repay_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_picker_behavior.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_selection.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';

/// Payment method → confirm repay → success.
class BorrowRepayNavigation {
  BorrowRepayNavigation._();

  static Future<void> startRepayFlow(
    BuildContext context, {
    required String projectId,
    required String projectName,
    required MyBorrowApprovedUiData approved,
  }) async {
    final selection = await context.push<PaymentMethodSelection>(
      AppRoutes.selectPaymentMethod,
      extra: PaymentMethodPickerBehavior.returnSelection,
    );
    if (!context.mounted || selection == null) return;

    final paymentLabel = switch (selection) {
      CardPaymentMethodSelection(:final card) => '${card.brandName} - ${card.last4}',
      WalletPaymentMethodSelection() => AppStrings.walletTitle,
    };

    if (!context.mounted) return;

    context.push(
      AppRoutes.borrowRepayConfirm,
      extra: BorrowRepayConfirmRouteArgs(
        projectId: projectId,
        projectName: projectName,
        repayAmount: approved.borrowAmount,
        totalRepayment: approved.totalRepaymentDue,
        dueDateLabel: approved.dueDateLabel,
        paymentMethodLabel: paymentLabel,
        penaltyPercent: approved.penaltyPercent,
        penaltyAmount: approved.penaltyAmount,
      ),
    );
  }
}
