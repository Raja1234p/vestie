import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/services/payment_methods_prefetch.dart';
import 'package:vestie/features/payment_methods/domain/payment_methods_cache.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_picker_behavior.dart';
import 'package:vestie/features/profile/domain/payment_method_auto_select.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';

/// Deposit amount → payment selection → confirm (cache-first).
abstract final class WalletDepositNavigation {
  WalletDepositNavigation._();

  static void continueFromAmount(
    BuildContext context,
    WalletTransactionCubit cubit,
  ) {
    final cached = PaymentMethodsCache.value;
    if (cached != null) {
      _openNext(context, cubit, cached);
      unawaited(PaymentMethodsPrefetch.refresh());
      return;
    }
    _openNextAfterFetch(context, cubit);
  }

  static Future<void> _openNextAfterFetch(
    BuildContext context,
    WalletTransactionCubit cubit,
  ) async {
    await PaymentMethodsPrefetch.warmIfNeeded();
    if (!context.mounted) return;
    final cards = PaymentMethodsCache.value;
    if (cards == null) {
      context.push(
        AppRoutes.selectPaymentMethod,
        extra: PaymentMethodPickerBehavior.depositFlow,
      );
      return;
    }
    _openNext(context, cubit, cards);
  }

  static void _openNext(
    BuildContext context,
    WalletTransactionCubit cubit,
    List<PaymentCard> cards,
  ) {
    final autoCard = PaymentMethodAutoSelect.resolve(cards);
    if (autoCard != null) {
      cubit.selectCard(autoCard);
      context.push(AppRoutes.transactionConfirmation);
      return;
    }
    context.push(
      AppRoutes.selectPaymentMethod,
      extra: PaymentMethodPickerBehavior.depositFlow,
    );
  }
}
