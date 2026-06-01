import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final BaseApiClient apiClient;

  WalletRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WalletModel> getWallet() async {
    final response = await apiClient.get<Map<String, dynamic>>(ApiConstants.wallet);
    return WalletModel.fromJson(response);
  }
}
