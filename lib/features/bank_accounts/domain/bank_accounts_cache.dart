import 'entities/bank_account_entity.dart';

class BankAccountsCache {
  BankAccountsCache._();

  static List<BankAccountEntity>? _cached;

  static List<BankAccountEntity>? get value => _cached;

  static void update(List<BankAccountEntity> accounts) =>
      _cached = List.unmodifiable(accounts);

  static void clear() => _cached = null;
}
