enum CardBrand { visa, mastercard, other }

class PaymentCard {
  final String id;
  final String holderName;
  final String last4;
  final String maskedNumber; // e.g. "•••• 0283"
  final String expiry;       // MM/YY
  final CardBrand brand;
  final bool isPrimary;

  const PaymentCard({
    required this.id,
    required this.holderName,
    required this.last4,
    required this.maskedNumber,
    required this.expiry,
    required this.brand,
    this.isPrimary = false,
  });

  PaymentCard copyWith({bool? isPrimary}) {
    return PaymentCard(
      id: id,
      holderName: holderName,
      last4: last4,
      maskedNumber: maskedNumber,
      expiry: expiry,
      brand: brand,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  String get brandName {
    switch (brand) {
      case CardBrand.visa:        return 'Visa';
      case CardBrand.mastercard:  return 'Master';
      case CardBrand.other:       return 'Card';
    }
  }
}
