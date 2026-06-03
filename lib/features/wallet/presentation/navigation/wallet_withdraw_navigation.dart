import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/services/bank_accounts_prefetch.dart';
import 'package:vestie/features/bank_accounts/domain/bank_account_auto_select.dart';
import 'package:vestie/features/bank_accounts/domain/bank_accounts_cache.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_transaction_cubit.dart';

/// Withdraw method → bank selection → confirm (cache-first, like deposit cards).
abstract final class WalletWithdrawNavigation {
  WalletWithdrawNavigation._();

  static void continueFromMethod(
    BuildContext context,
    WalletTransactionCubit cubit,
  ) {
    final cached = BankAccountsCache.value;
    if (cached != null) {
      _openNext(context, cubit, cached);
      unawaited(BankAccountsPrefetch.refresh());
      return;
    }
    _openNextAfterFetch(context, cubit);
  }

  static Future<void> _openNextAfterFetch(
    BuildContext context,
    WalletTransactionCubit cubit,
  ) async {
    await BankAccountsPrefetch.warmIfNeeded();
    if (!context.mounted) return;
    final accounts = BankAccountsCache.value;
    if (accounts == null || accounts.isEmpty) {
      context.push(AppRoutes.selectBankAccount);
      return;
    }
    _openNext(context, cubit, accounts);
  }

  static void _openNext(
    BuildContext context,
    WalletTransactionCubit cubit,
    List<BankAccountEntity> accounts,
  ) {
    final auto = BankAccountAutoSelect.resolve(accounts);
    if (auto != null) {
      cubit.selectBankAccount(
        bankAccountId: auto.id,
        displayName: auto.displayName,
      );
      context.push(AppRoutes.transactionConfirmation);
      return;
    }
    context.push(AppRoutes.selectBankAccount);
  }
}
