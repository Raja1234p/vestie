import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/services/wallet_prefetch.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';
import 'package:vestie/features/wallet/domain/usecases/get_wallet_use_case.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';
import 'package:vestie/features/wallet/presentation/mappers/wallet_transaction_ui_mapper.dart';

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
      recentActivity: WalletTransactionUiMapper.toTransactions(
        wallet.recentTransactions,
      ),
      clearFailure: true,
    ));
  }

  void invalidateCache() {
    WalletBalanceCache.clear();
  }

  /// Clears tab state on logout (wallet reloads on next tab open).
  void reset() => emit(const WalletState());
}
