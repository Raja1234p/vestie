import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';

/// When the withdraw bank picker can be skipped.
abstract final class BankAccountAutoSelect {
  BankAccountAutoSelect._();

  /// Exactly one linked account marked default — auto-select for withdraw.
  static BankAccountEntity? resolve(List<BankAccountEntity> accounts) {
    if (accounts.length != 1) return null;
    final only = accounts.first;
    return only.isDefault ? only : null;
  }
}
