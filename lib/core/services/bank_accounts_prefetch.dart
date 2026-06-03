import 'dart:async';

import '../di/service_locator.dart';

/// Warms [BankAccountsCache] after login (Home/Dashboard) so withdraw flow is instant.
abstract final class BankAccountsPrefetch {
  BankAccountsPrefetch._();

  static Future<void>? _inFlight;

  /// Fetches bank accounts when cache is empty; no-op if already cached.
  static Future<void> warmIfNeeded() {
    final existing = _inFlight;
    if (existing != null) return existing;

    _inFlight = _warmIfNeededBody();
    return _inFlight!.whenComplete(() => _inFlight = null);
  }

  /// Always refreshes from API (silent background).
  static Future<void> refresh() async {
    try {
      await ServiceLocator.instance.listBankAccountsUseCase(forceRefresh: true);
    } catch (_) {}
  }

  static Future<void> _warmIfNeededBody() async {
    await ServiceLocator.instance.listBankAccountsUseCase();
  }
}
