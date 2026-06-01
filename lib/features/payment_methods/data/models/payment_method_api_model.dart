import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

class PaymentMethodApiModel {
  final String id;
  final String? holderName;
  final String last4;
  final String? maskedNumber;
  final String? expiry;
  final String brand;
  final bool isPrimary;

  const PaymentMethodApiModel({
    required this.id,
    this.holderName,
    required this.last4,
    this.maskedNumber,
    this.expiry,
    required this.brand,
    this.isPrimary = false,
  });

  factory PaymentMethodApiModel.fromJson(Map<String, dynamic> json) {
    final expMonth = json['expMonth'] ?? json['exp_month'];
    final expYear = json['expYear'] ?? json['exp_year'];
    String? expiry;
    if (expMonth != null && expYear != null) {
      final m = expMonth.toString().padLeft(2, '0');
      final y = expYear.toString();
      final yy = y.length >= 2 ? y.substring(y.length - 2) : y;
      expiry = '$m/$yy';
    }

    return PaymentMethodApiModel(
      id: json.safeString('id'),
      holderName: json.safeStringNullable('holderName') ??
          json.safeStringNullable('cardholderName'),
      last4: json.safeString('last4'),
      maskedNumber: json.safeStringNullable('maskedNumber'),
      expiry: expiry ?? json.safeStringNullable('expiry'),
      brand: json.safeString('brand', defaultValue: 'card'),
      isPrimary: json.safeBool('isPrimary') || json.safeBool('isDefault'),
    );
  }

  PaymentCard toCard() {
    final last = last4.isNotEmpty ? last4 : '0000';
    return PaymentCard(
      id: id,
      holderName: holderName?.trim().isNotEmpty == true
          ? holderName!.trim()
          : 'Cardholder',
      last4: last,
      maskedNumber: maskedNumber ?? '•••• $last',
      expiry: expiry ?? '--/--',
      brand: _mapBrand(brand),
      isPrimary: isPrimary,
    );
  }

  CardBrand _mapBrand(String raw) {
    final b = raw.toLowerCase();
    if (b.contains('visa')) return CardBrand.visa;
    if (b.contains('master')) return CardBrand.mastercard;
    return CardBrand.other;
  }
}
