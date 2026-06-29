import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/utils/formatters.dart';
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
    case TransactionType.repayment:
      return AppTransactionType.lend;
    case TransactionType.fee:
      return AppTransactionType.withdrawal;
  }
}

/// Recent activity list — uses [AppTransactionItem] with 12.h gaps (Figma).
class WalletRecentActivityList extends StatelessWidget {
  const WalletRecentActivityList({
    super.key,
    required this.transactions,
    this.scrollController,
    this.footer,
  });

  final List<Transaction> transactions;
  final ScrollController? scrollController;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final footerWidget = footer;
    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.only(bottom: 16.h),
      physics: const BouncingScrollPhysics(),
      itemCount: transactions.length + (footerWidget != null ? 1 : 0),
      separatorBuilder: (context, index) {
        if (footerWidget != null && index >= transactions.length - 1) {
          return const SizedBox.shrink();
        }
        return SizedBox(height: AppDimens.walletTransactionRowGap);
      },
      itemBuilder: (_, index) {
        if (footerWidget != null && index == transactions.length) {
          return footerWidget;
        }
        final tx = transactions[index];
        return AppTransactionItem(
          spacing: AppTransactionItemSpacing.list,
          type: walletTransactionTypeFromEntity(tx.type),
          title: tx.title,
          date: tx.date,
          amount: AppFormatters.formatMoneyAmount(tx.amount.abs()),
          isNegative: !tx.isPositive,
        );
      },
    );
  }
}
