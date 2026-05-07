import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';
import '../models/contribution_config_model.dart';
import '../models/contribution_preview_model.dart';

abstract class ContributionRemoteDataSource {
  Future<ContributionConfigModel> getContributionConfig(String projectId);
  Future<ContributionPreviewModel> previewContribution(String projectId, double amount);
  Future<void> confirmContribution(String projectId, double amount, String walletId);
}

class ContributionRemoteDataSourceImpl implements ContributionRemoteDataSource {
  final BaseApiClient apiClient;

  ContributionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ContributionConfigModel> getContributionConfig(String projectId) async {
    final response = await apiClient.get<Map<String, dynamic>>('${ApiConstants.baseUrl}/contributions/projects/$projectId/config');
    return ContributionConfigModel.fromJson(response);
  }

  @override
  Future<ContributionPreviewModel> previewContribution(String projectId, double amount) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/contributions/preview',
      data: {
        'projectId': projectId,
        'amount': amount,
      },
    );
    return ContributionPreviewModel.fromJson(response);
  }

  @override
  Future<void> confirmContribution(String projectId, double amount, String walletId) async {
    await apiClient.post(
      '${ApiConstants.baseUrl}/contributions/confirm',
      data: {
        'projectId': projectId,
        'amount': amount,
        'walletId': walletId,
      },
    );
  }
}
