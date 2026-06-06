import 'entities/bank_account_entity.dart';

class BankAccountsCache {
  BankAccountsCache._();

  static List<BankAccountEntity>? _cached;

  static List<BankAccountEntity>? get value => _cached;

  static void update(List<BankAccountEntity> accounts) =>
      _cached = List.unmodifiable(accounts);

  static void updateDefault(String bankAccountId, {required bool isDefault}) {
    final current = _cached;
    if (current == null) return;
    update(
      current
          .map(
            (a) => BankAccountEntity(
              id: a.id,
              bankName: a.bankName,
              last4: a.last4,
              currency: a.currency,
              isDefault: isDefault
                  ? a.id == bankAccountId
                  : (a.id == bankAccountId ? false : a.isDefault),
              displayName: a.displayName,
            ),
          )
          .toList(growable: false),
    );
  }

  static void removeById(String bankAccountId) {
    final current = _cached;
    if (current == null) return;
    update(current.where((a) => a.id != bankAccountId).toList(growable: false));
  }

  static void clear() => _cached = null;
}
