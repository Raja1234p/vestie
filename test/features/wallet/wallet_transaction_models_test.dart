import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/features/wallet/data/models/wallet_model.dart';
import 'package:vestie/features/wallet/data/models/wallet_transactions_page_model.dart';
import 'package:vestie/features/wallet/presentation/mappers/wallet_transaction_ui_mapper.dart';

void main() {
  group('WalletRecentTransactionModel', () {
    test('fromJson maps description and createdAtUtc from ledger API', () {
      final model = WalletRecentTransactionModel.fromJson({
        'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'type': 'Deposit',
        'description': 'Wallet Deposit',
        'amount': 500,
        'direction': 'Credit',
        'status': 'Completed',
        'reference': 'pi_3abc',
        'projectId': null,
        'projectName': null,
        'date': '2026-03-12',
        'createdAtUtc': '2026-03-12T10:30:00+00:00',
      });

      expect(model.title, 'Wallet Deposit');
      expect(model.type, 'Deposit');
      expect(model.amount, 500);
      expect(model.isDebit, isFalse);
      expect(model.dateUtc, isNotNull);
    });

    test('fromJson falls back to title when description is empty', () {
      final model = WalletRecentTransactionModel.fromJson({
        'id': 'tx-1',
        'type': 'Withdrawal',
        'title': 'Wallet Withdrawal',
        'amount': 100,
        'direction': 'Debit',
      });

      expect(model.title, 'Wallet Withdrawal');
      expect(model.isDebit, isTrue);
    });
  });

  group('WalletTransactionsPageModel', () {
    test('fromJson parses transactions list and pagination', () {
      final page = WalletTransactionsPageModel.fromJson({
        'transactions': [
          {
            'id': 'tx-1',
            'type': 'Contribution',
            'description': 'Contribution: Family Vacation',
            'amount': 115,
            'direction': 'Debit',
            'status': 'Completed',
            'date': '2026-03-11',
            'createdAtUtc': '2026-03-11T14:20:00+00:00',
          },
        ],
        'pagination': {
          'page': 1,
          'pageSize': 20,
          'totalCount': 6,
          'totalPages': 1,
        },
      });

      expect(page.transactions, hasLength(1));
      expect(page.transactions.first.title, 'Contribution: Family Vacation');
      expect(page.pagination.totalCount, 6);
    });
  });

  group('WalletTransactionUiMapper', () {
    test('maps debit contribution with signed amount', () {
      final tx = WalletTransactionUiMapper.toTransaction(
        const WalletRecentTransactionModel(
          id: 'tx-1',
          type: 'Contribution',
          title: 'Contribution: Family Vacation',
          amount: 115,
          direction: 'Debit',
        ),
      );

      expect(tx.amount, -115);
      expect(tx.isPositive, isFalse);
    });
  });
}
