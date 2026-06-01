import 'package:equatable/equatable.dart';

class BankAccountEntity extends Equatable {
  final String id;
  final String bankName;
  final String last4;
  final String currency;
  final bool isDefault;
  final String displayName;

  const BankAccountEntity({
    required this.id,
    required this.bankName,
    required this.last4,
    required this.currency,
    required this.isDefault,
    required this.displayName,
  });

  @override
  List<Object?> get props => [id, bankName, last4, currency, isDefault, displayName];
}
