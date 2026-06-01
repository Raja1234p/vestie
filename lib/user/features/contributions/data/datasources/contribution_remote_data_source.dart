import 'package:dio/dio.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/contribution_config_model.dart';
import '../models/contribution_submit_result_model.dart';

abstract class ContributionRemoteDataSource {
  Future<ContributionConfigModel> getContributionConfig(String projectId);

  Future<ContributionSubmitResultModel> submitProjectContribution({
    required String projectId,
    required double amount,
    required bool confirmNonRefundable,
    required String idempotencyKey,
  });
}

class ContributionRemoteDataSourceImpl implements ContributionRemoteDataSource {
  final BaseApiClient apiClient;

  ContributionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ContributionConfigModel> getContributionConfig(String projectId) async {
    return ContributionConfigModel(
      projectId: projectId,
      projectCurrency: 'USD',
      platformFeeRatePercent: 15,
      minimumContributionAmount: 5,
      isNonRefundable: true,
      suggestedContributionAmount: 50,
      wallets: const [],
    );
  }

  @override
  Future<ContributionSubmitResultModel> submitProjectContribution({
    required String projectId,
    required double amount,
    required bool confirmNonRefundable,
    required String idempotencyKey,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectContributions(projectId),
      data: {
        'amount': amount,
        'confirmNonRefundable': confirmNonRefundable,
      },
      options: Options(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    return ContributionSubmitResultModel.fromJson(response);
  }
}
