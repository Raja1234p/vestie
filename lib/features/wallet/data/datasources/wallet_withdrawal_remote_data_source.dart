import 'package:dio/dio.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/withdrawal_models.dart';

abstract class WalletWithdrawalRemoteDataSource {
  Future<WithdrawalPreviewModel> preview({
    required double amount,
    required String type,
    String? bankAccountId,
  });

  Future<WithdrawalSubmitModel> submit({
    required double amount,
    required String type,
    required String bankAccountId,
    required String idempotencyKey,
  });

  Future<WithdrawalStatusModel> getStatus(String withdrawalId);
}

class WalletWithdrawalRemoteDataSourceImpl
    implements WalletWithdrawalRemoteDataSource {
  final BaseApiClient apiClient;

  WalletWithdrawalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WithdrawalPreviewModel> preview({
    required double amount,
    required String type,
    String? bankAccountId,
  }) async {
    final data = <String, dynamic>{'amount': amount, 'type': type};
    final bankId = bankAccountId?.trim();
    if (bankId != null && bankId.isNotEmpty) {
      data['bankAccountId'] = bankId;
    }
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.walletWithdrawalsPreview,
      data: data,
    );
    return WithdrawalPreviewModel.fromJson(response);
  }

  @override
  Future<WithdrawalSubmitModel> submit({
    required double amount,
    required String type,
    required String bankAccountId,
    required String idempotencyKey,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.walletWithdrawals,
      data: {
        'amount': amount,
        'type': type,
        'bankAccountId': bankAccountId,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return WithdrawalSubmitModel.fromJson(response);
  }

  @override
  Future<WithdrawalStatusModel> getStatus(String withdrawalId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.walletWithdrawalStatus(withdrawalId),
    );
    return WithdrawalStatusModel.fromJson(response);
  }
}
