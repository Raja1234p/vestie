import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/profile/domain/entities/transaction.dart';

abstract final class TransactionHistoryFilter {
  TransactionHistoryFilter._();

  static List<Transaction> apply(
    List<Transaction> list,
    String filter,
  ) {
    switch (filter) {
      case AppStrings.filterDeposits:
        return list.where((t) => t.isDeposit).toList(growable: false);
      case AppStrings.filterBorrow:
        return list.where((t) => t.isBorrow).toList(growable: false);
      case AppStrings.filterWithdrawals:
        return list.where((t) => t.isWithdrawal).toList(growable: false);
      case AppStrings.filterContributions:
        return list.where((t) => t.isContribution).toList(growable: false);
      case AppStrings.filterRepayments:
        return list.where((t) => t.isRepayment).toList(growable: false);
      case AppStrings.filterFees:
        return list.where((t) => t.isFee).toList(growable: false);
      case AppStrings.filterUpcoming:
        return list.where((t) => t.isUpcoming).toList(growable: false);
      default:
        return list;
    }
  }
}
