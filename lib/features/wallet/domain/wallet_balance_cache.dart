import 'entities/wallet_entity.dart';

/// Session cache for wallet balances (invalidate on deposit, contribution, logout).
class WalletBalanceCache {
  WalletBalanceCache._();

  static WalletEntity? _cached;

  static WalletEntity? get value => _cached;

  static void update(WalletEntity wallet) => _cached = wallet;

  static void clear() => _cached = null;
}
