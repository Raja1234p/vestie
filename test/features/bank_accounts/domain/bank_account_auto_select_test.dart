import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/bank_accounts/domain/bank_account_auto_select.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';

BankAccountEntity _account({required bool isDefault}) => BankAccountEntity(
      id: 'ba_1',
      bankName: 'Test',
      last4: '1234',
      currency: 'usd',
      isDefault: isDefault,
      displayName: 'Test - 1234',
    );

void main() {
  test('auto-selects single default account', () {
    final result = BankAccountAutoSelect.resolve([_account(isDefault: true)]);
    expect(result?.id, 'ba_1');
  });

  test('does not auto-select single non-default account', () {
    expect(BankAccountAutoSelect.resolve([_account(isDefault: false)]), isNull);
  });

  test('does not auto-select when multiple accounts', () {
    expect(
      BankAccountAutoSelect.resolve([
        _account(isDefault: true),
        _account(isDefault: false),
      ]),
      isNull,
    );
  });
}
