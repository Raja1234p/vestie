import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';
import 'package:vestie/features/profile/presentation/utils/transaction_history_filter.dart';

void main() {
  const sample = [
    Transaction(
      id: '1',
      title: 'Wallet Deposit',
      date: 'Mar 12',
      amount: 500,
      type: TransactionType.deposit,
    ),
    Transaction(
      id: '2',
      title: 'Borrow: Vacation',
      date: 'Mar 12',
      amount: 650,
      type: TransactionType.borrow,
    ),
  ];

  test('Deposits filter excludes borrow rows', () {
    final filtered = TransactionHistoryFilter.apply(
      sample,
      AppStrings.filterDeposits,
    );
    expect(filtered, hasLength(1));
    expect(filtered.first.type, TransactionType.deposit);
  });

  test('Borrow filter shows only borrow rows', () {
    final filtered = TransactionHistoryFilter.apply(
      sample,
      AppStrings.filterBorrow,
    );
    expect(filtered, hasLength(1));
    expect(filtered.first.type, TransactionType.borrow);
  });
}
