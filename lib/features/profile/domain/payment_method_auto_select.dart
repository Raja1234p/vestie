import 'package:vestie/features/profile/domain/entities/payment_card.dart';

/// When the payment-method picker can be skipped (single card or a primary/default).
abstract final class PaymentMethodAutoSelect {
  PaymentMethodAutoSelect._();

  /// One card, or the primary card when several exist; otherwise user must pick.
  static PaymentCard? resolve(List<PaymentCard> cards) {
    if (cards.isEmpty) return null;
    if (cards.length == 1) return cards.first;
    for (final card in cards) {
      if (card.isPrimary) return card;
    }
    return null;
  }
}
