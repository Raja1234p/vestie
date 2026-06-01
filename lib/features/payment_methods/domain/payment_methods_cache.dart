import 'package:vestie/features/profile/domain/entities/payment_card.dart';

class PaymentMethodsCache {
  PaymentMethodsCache._();

  static List<PaymentCard>? _cached;

  static List<PaymentCard>? get value => _cached;

  static void update(List<PaymentCard> cards) => _cached = List.unmodifiable(cards);

  static void clear() => _cached = null;
}
