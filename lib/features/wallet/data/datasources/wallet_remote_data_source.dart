import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/wallet_model.dart';
import '../models/wallet_transactions_page_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();

  Future<WalletTransactionsPageModel> getTransactions({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final BaseApiClient apiClient;

  WalletRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WalletModel> getWallet() async {
    final response = await apiClient.get<Map<String, dynamic>>(ApiConstants.wallet);
    return WalletModel.fromJson(response);
  }

  @override
  Future<WalletTransactionsPageModel> getTransactions({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.walletTransactions,
      queryParameters: PaginationQuery.pageAndSize(
        page: page,
        pageSize: pageSize,
      ),
    );
    return WalletTransactionsPageModel.fromJson(response);
  }
}
