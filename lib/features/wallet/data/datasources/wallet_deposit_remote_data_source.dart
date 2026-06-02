import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';
import '../models/wallet_deposit_models.dart';

abstract class WalletDepositRemoteDataSource {
  Future<WalletDepositIntentModel> createDepositIntent({
    required double amount,
    required String paymentMethodId,
    required String idempotencyKey,
  });

  Future<WalletDepositStatusModel> getDepositStatus(String paymentIntentId);

  /// Dev-only backend shortcut (`POST /wallet/deposit`). Not used in app deposit flow.
  Future<void> simulateDeposit({required double amount});
}

class WalletDepositRemoteDataSourceImpl implements WalletDepositRemoteDataSource {
  final BaseApiClient apiClient;

  WalletDepositRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WalletDepositIntentModel> createDepositIntent({
    required double amount,
    required String paymentMethodId,
    required String idempotencyKey,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.walletDepositIntent,
      data: {
        'amount': amount,
        'paymentMethodId': paymentMethodId,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return WalletDepositIntentModel.fromJson(response);
  }

  @override
  Future<WalletDepositStatusModel> getDepositStatus(String paymentIntentId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.walletDepositStatus(paymentIntentId),
    );
    return WalletDepositStatusModel.fromJson(response);
  }

  @override
  Future<void> simulateDeposit({required double amount}) async {
    if (!kDebugMode) return;
    await apiClient.post<Map<String, dynamic>>(
      ApiConstants.walletDepositSimulated,
      data: {'amount': amount},
    );
  }
}
