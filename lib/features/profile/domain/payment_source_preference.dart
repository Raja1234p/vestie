import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/domain/payment_method_auto_select.dart';

/// Resolves wallet vs saved card for contribute / repay flows.
abstract final class PaymentSourcePreference {
  PaymentSourcePreference._();

  /// Wallet when balance covers [requiredTotal]; otherwise primary or sole card.
  static ({bool payFromWallet, PaymentCard? card}) resolve({
    required double walletBalance,
    required double requiredTotal,
    required List<PaymentCard> cards,
  }) {
    if (walletBalance >= requiredTotal) {
      return (payFromWallet: true, card: null);
    }
    return (payFromWallet: false, card: PaymentMethodAutoSelect.resolve(cards));
  }

  /// Default saved card id from API borrow-repay options (`isDefault` / single card).
  static String? preferredCardId(
    List<({String id, bool isDefault})> cards,
  ) {
    if (cards.isEmpty) return null;
    if (cards.length == 1) return cards.first.id;
    for (final card in cards) {
      if (card.isDefault) return card.id;
    }
    return null;
  }

  /// User must open the payment picker (multiple cards, no primary / default).
  static bool requiresUserPicker({
    required double walletBalance,
    required double requiredTotal,
    required List<PaymentCard> cards,
  }) {
    if (walletBalance >= requiredTotal) return false;
    return PaymentMethodAutoSelect.resolve(cards) == null;
  }

  /// Show change-payment affordance (chevron / picker entry).
  static bool canChangePaymentMethod({
    required double walletBalance,
    required double requiredTotal,
    required List<PaymentCard> cards,
  }) {
    if (walletBalance >= requiredTotal) return cards.isNotEmpty;
    return requiresUserPicker(
          walletBalance: walletBalance,
          requiredTotal: requiredTotal,
          cards: cards,
        ) ||
        cards.isNotEmpty;
  }
}
