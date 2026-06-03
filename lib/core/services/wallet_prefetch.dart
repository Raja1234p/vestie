import 'dart:async';

import '../di/service_locator.dart';
import '../../features/wallet/domain/wallet_balance_cache.dart';

/// Warms [WalletBalanceCache] after login (Home / Dashboard) so contribute/deposit
/// flows show the real balance immediately.
abstract final class WalletPrefetch {
  WalletPrefetch._();

  static Future<void>? _inFlight;

  /// Fetches wallet when cache is empty; no-op if already cached.
  static Future<void> warmIfNeeded() {
    if (WalletBalanceCache.value != null) return Future.value();

    final existing = _inFlight;
    if (existing != null) return existing;

    _inFlight = _warmIfNeededBody();
    return _inFlight!.whenComplete(() => _inFlight = null);
  }

  /// Always refreshes from API (silent background).
  static Future<void> refresh() async {
    try {
      await ServiceLocator.instance.getWalletUseCase(forceRefresh: true);
    } catch (_) {}
  }

  static Future<void> _warmIfNeededBody() async {
    await ServiceLocator.instance.getWalletUseCase();
  }
}
