import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/contribute_payment_picker_args.dart';
import 'package:vestie/core/services/payment_methods_prefetch.dart';
import 'package:vestie/core/utils/formatters.dart';
import 'package:vestie/user/features/contributions/presentation/bloc/contribute_state.dart';

/// Cache-first payment picker for contribute (mirrors wallet deposit navigation).
abstract final class ContributePaymentNavigation {
  ContributePaymentNavigation._();

  static Future<Object?> openPicker(
    BuildContext context, {
    required ContributeState state,
  }) async {
    final args = state.args;
    if (args == null) return null;

    final pickerArgs = ContributePaymentPickerArgs(
      walletBalance: state.walletBalance,
      requiredTotal: state.totalDeductionValue,
      walletAmountFormatted: AppFormatters.formatCurrency(state.walletBalance),
      initialPayFromWallet: state.payFromWallet,
      initialSelectedCardId: state.selectedCard?.id,
    );

    await PaymentMethodsPrefetch.warmIfNeeded();
    if (!context.mounted) return null;

    return context.push(AppRoutes.contributePaymentPicker, extra: pickerArgs);
  }
}
