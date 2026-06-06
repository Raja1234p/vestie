import 'package:vestie/features/profile/domain/entities/payment_card.dart';

/// In-memory payment methods for instant deposit / contribute flows.
class PaymentMethodsCache {
  PaymentMethodsCache._();

  static List<PaymentCard>? _cached;

  static List<PaymentCard>? get value => _cached;

  static void update(List<PaymentCard> cards) =>
      _cached = List.unmodifiable(cards);

  static void upsert(PaymentCard card) {
    final current = _cached;
    if (current == null) {
      update([card]);
      return;
    }
    final next = <PaymentCard>[
      for (final existing in current)
        if (existing.id != card.id) existing,
      card,
    ];
    update(next);
  }

  static void setPrimary(String paymentMethodId) {
    final current = _cached;
    if (current == null) return;
    update(
      current
          .map((c) => c.copyWith(isPrimary: c.id == paymentMethodId))
          .toList(growable: false),
    );
  }

  static void removeById(String paymentMethodId) {
    final current = _cached;
    if (current == null) return;
    update(
      current.where((c) => c.id != paymentMethodId).toList(growable: false),
    );
  }

  static void clear() => _cached = null;
}
