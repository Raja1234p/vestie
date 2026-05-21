import 'payment_card.dart';

/// Result from the payment-method picker (card or in-app wallet).
sealed class PaymentMethodSelection {
  const PaymentMethodSelection();
}

final class CardPaymentMethodSelection extends PaymentMethodSelection {
  const CardPaymentMethodSelection(this.card);
  final PaymentCard card;
}

final class WalletPaymentMethodSelection extends PaymentMethodSelection {
  const WalletPaymentMethodSelection();
}
