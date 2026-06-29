import 'package:vestie/core/models/pagination_dto.dart';

import 'wallet_model.dart';

/// `GET /wallet/transactions` — paginated transaction history.
class WalletTransactionsPageModel {
  final List<WalletRecentTransactionModel> transactions;
  final PaginationDto pagination;

  const WalletTransactionsPageModel({
    required this.transactions,
    required this.pagination,
  });

  factory WalletTransactionsPageModel.fromJson(Map<String, dynamic> json) {
    final parsed = PaginatedListParser.parse(
      json,
      WalletRecentTransactionModel.fromJson,
      legacyListKeys: const ['items', 'transactions', 'data', 'results'],
    );
    return WalletTransactionsPageModel(
      transactions: parsed.items,
      pagination: parsed.pagination,
    );
  }
}
