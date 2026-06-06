import 'dart:async';

import '../../features/payment_methods/domain/payment_methods_cache.dart';
import '../di/service_locator.dart';

/// Warms [PaymentMethodsCache] after login (e.g. Home tab) so deposit flow is instant.
abstract final class PaymentMethodsPrefetch {
  PaymentMethodsPrefetch._();

  static Future<void>? _inFlight;

  /// Fetches payment methods when cache is empty; no-op if already cached.
  static Future<void> warmIfNeeded() {
    if (PaymentMethodsCache.value != null) return Future.value();

    final existing = _inFlight;
    if (existing != null) return existing;

    _inFlight = _warmIfNeededBody();
    return _inFlight!.whenComplete(() => _inFlight = null);
  }

  /// Always refreshes from API (silent background).
  static Future<void> refresh() async {
    try {
      await ServiceLocator.instance.listPaymentMethodsUseCase(
        forceRefresh: true,
      );
    } catch (_) {}
  }

  static Future<void> _warmIfNeededBody() async {
    await ServiceLocator.instance.listPaymentMethodsUseCase();
  }
}
