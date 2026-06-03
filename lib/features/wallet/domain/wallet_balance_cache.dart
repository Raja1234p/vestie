import 'entities/wallet_entity.dart';

/// Session cache for wallet balances (invalidate on deposit, contribution, logout).
class WalletBalanceCache {
  WalletBalanceCache._();

  static WalletEntity? _cached;

  static WalletEntity? get value => _cached;

  static void update(WalletEntity wallet) => _cached = wallet;

  /// Updates cached available (and wallet) balance after contribute / deposit.
  static void patchAvailableBalance(double availableBalance) {
    final w = _cached;
    if (w == null) return;
    _cached = WalletEntity(
      walletId: w.walletId,
      currency: w.currency,
      walletBalance: availableBalance,
      availableBalance: availableBalance,
      borrowedBalance: w.borrowedBalance,
      borrowed: w.borrowed,
      lockedInProjects: w.lockedInProjects,
      pendingWithdrawal: w.pendingWithdrawal,
      recentTransactions: w.recentTransactions,
    );
  }

  static void clear() => _cached = null;
}
