import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';
import '../models/contribution_config_model.dart';
import '../models/contribution_preview_model.dart';

abstract class ContributionRemoteDataSource {
  Future<ContributionConfigModel> getContributionConfig(String projectId);
  Future<ContributionPreviewModel> previewContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  });
  Future<void> confirmContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  });
}

class ContributionRemoteDataSourceImpl implements ContributionRemoteDataSource {
  final BaseApiClient apiClient;

  ContributionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ContributionConfigModel> getContributionConfig(String projectId) async {
    final response = await apiClient.get<Map<String, dynamic>>('${ApiConstants.contributions}/projects/$projectId/config');
    return ContributionConfigModel.fromJson(response);
  }

  @override
  Future<ContributionPreviewModel> previewContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.contributions}/preview',
      data: {
        'projectId': projectId,
        'membershipId': membershipId,
        'walletId': walletId,
        'amount': amount,
        'currency': currency,
        'externalReference': externalReference,
        'confirmNonRefundable': confirmNonRefundable,
      },
    );
    return ContributionPreviewModel.fromJson(response);
  }

  @override
  Future<void> confirmContribution({
    required String projectId,
    required String membershipId,
    required String walletId,
    required double amount,
    required String currency,
    String? externalReference,
    required bool confirmNonRefundable,
  }) async {
    await apiClient.post(
      '${ApiConstants.contributions}/confirm',
      data: {
        'projectId': projectId,
        'membershipId': membershipId,
        'amount': amount,
        'walletId': walletId,
        'currency': currency,
        'externalReference': externalReference,
        'confirmNonRefundable': confirmNonRefundable,
      },
    );
  }
}
