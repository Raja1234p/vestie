import 'package:intl/intl.dart';

import 'package:vestie/features/profile/domain/entities/transaction.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';

/// Maps wallet ledger API rows to profile [Transaction] UI models.
abstract final class WalletTransactionUiMapper {
  WalletTransactionUiMapper._();

  static final DateFormat _dateFmt = DateFormat('MMM d');

  static List<Transaction> toTransactions(
    List<WalletRecentTransactionEntity> raw,
  ) {
    if (raw.isEmpty) return const [];
    return raw.map(toTransaction).toList(growable: false);
  }

  static Transaction toTransaction(WalletRecentTransactionEntity entity) {
    final signed =
        entity.isDebit ? -entity.amount.abs() : entity.amount.abs();
    return Transaction(
      id: entity.id,
      title: entity.title,
      date: entity.dateUtc != null
          ? _dateFmt.format(entity.dateUtc!.toLocal())
          : '',
      amount: signed,
      type: mapApiType(entity.type),
    );
  }

  static TransactionType mapApiType(String apiType) {
    switch (apiType.toLowerCase()) {
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'contribution':
        return TransactionType.contribution;
      case 'deposit':
        return TransactionType.deposit;
      case 'repayment':
        return TransactionType.repayment;
      case 'fee':
        return TransactionType.fee;
      case 'borrow':
        return TransactionType.borrow;
      case 'upcoming':
      case 'upcmoing':
        return TransactionType.upcoming;
      default:
        return TransactionType.deposit;
    }
  }
}
