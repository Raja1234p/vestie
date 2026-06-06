import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:vestie/core/services/wallet_prefetch.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';
import 'package:vestie/features/wallet/domain/usecases/get_wallet_use_case.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';

import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final GetWalletUseCase getWalletUseCase;

  WalletCubit({required this.getWalletUseCase}) : super(const WalletState());

  /// Loads wallet data. When [forceRefresh] is false, hydrates from
  /// [WalletBalanceCache] or awaits [WalletPrefetch] (Home / Dashboard warm).
  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh && state.wallet != null) return;

    if (!forceRefresh) {
      final cached = WalletBalanceCache.value;
      if (cached != null) {
        _emitWallet(cached);
        return;
      }
    }

    emit(state.copyWith(isLoading: true, clearFailure: true));

    if (!forceRefresh) {
      await WalletPrefetch.warmIfNeeded();
      final warmed = WalletBalanceCache.value;
      if (warmed != null) {
        _emitWallet(warmed);
        return;
      }
    }

    final result = await getWalletUseCase(forceRefresh: forceRefresh);
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoading: false,
          failure: failure,
          wallet: null,
          recentActivity: const [],
        ));
      },
      (wallet) => _emitWallet(wallet),
    );
  }

  void _emitWallet(WalletEntity wallet) {
    emit(state.copyWith(
      isLoading: false,
      wallet: wallet,
      recentActivity: _mapTransactions(wallet),
      clearFailure: true,
    ));
  }

  void invalidateCache() {
    WalletBalanceCache.clear();
  }

  /// Clears tab state on logout (wallet reloads on next tab open).
  void reset() => emit(const WalletState());

  List<Transaction> _mapTransactions(WalletEntity wallet) {
    if (wallet.recentTransactions.isEmpty) {
      return const [];
    }
    final dateFmt = DateFormat('MMM d');
    return wallet.recentTransactions.map((t) {
      final signed = t.isDebit ? -t.amount.abs() : t.amount.abs();
      return Transaction(
        id: t.id,
        title: t.title,
        date: t.dateUtc != null ? dateFmt.format(t.dateUtc!.toLocal()) : '',
        amount: signed,
        type: _mapType(t.type),
      );
    }).toList(growable: false);
  }

  TransactionType _mapType(String apiType) {
    switch (apiType.toLowerCase()) {
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'contribution':
        return TransactionType.contribution;
      case 'deposit':
        return TransactionType.deposit;
      case 'repayment':
        return TransactionType.repayment;
      case 'fee':
        return TransactionType.fee;
      case 'borrow':
        return TransactionType.borrow;
      default:
        return TransactionType.deposit;
    }
  }
}
