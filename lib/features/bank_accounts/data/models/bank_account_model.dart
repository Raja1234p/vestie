import 'package:vestie/core/utils/safe_parser.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';

class BankAccountModel extends BankAccountEntity {
  const BankAccountModel({
    required super.id,
    required super.bankName,
    required super.last4,
    required super.currency,
    required super.isDefault,
    required super.displayName,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    final bankName = json.safeString('bankName');
    final last4 = json.safeString('last4');
    final display = json.safeStringNullable('displayName') ??
        (bankName.isNotEmpty && last4.isNotEmpty
            ? '$bankName - $last4'
            : bankName);

    return BankAccountModel(
      id: json.safeString('id'),
      bankName: bankName,
      last4: last4,
      currency: json.safeString('currency', defaultValue: 'usd'),
      isDefault: json.safeBool('isDefault'),
      displayName: display,
    );
  }
}
