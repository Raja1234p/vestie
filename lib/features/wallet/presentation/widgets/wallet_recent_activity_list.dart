import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/widgets/common/app_transaction_item.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';

/// Maps profile [TransactionType] to shared ledger row type.
AppTransactionType walletTransactionTypeFromEntity(TransactionType type) {
  switch (type) {
    case TransactionType.deposit:
      return AppTransactionType.deposit;
    case TransactionType.contribution:
      return AppTransactionType.contribution;
    case TransactionType.borrow:
      return AppTransactionType.borrow;
    case TransactionType.withdrawal:
      return AppTransactionType.withdrawal;
    case TransactionType.lend:
      return AppTransactionType.lend;
  }
}

/// Recent activity list — uses [AppTransactionItem] with 12.h gaps (Figma).
class WalletRecentActivityList extends StatelessWidget {
  const WalletRecentActivityList({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.h),
      physics: const BouncingScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: AppDimens.walletTransactionRowGap),
      itemBuilder: (_, index) {
        final tx = transactions[index];
        return AppTransactionItem(
          spacing: AppTransactionItemSpacing.list,
          type: walletTransactionTypeFromEntity(tx.type),
          title: tx.title,
          date: tx.date,
          amount: tx.amount.abs().toStringAsFixed(0),
          isNegative: !tx.isPositive,
        );
      },
    );
  }
}
