import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';
import '../models/investment_returns_response_models.dart';

abstract class InvestmentReturnsRemoteDataSource {
  Future<MyInvestmentReturnsResponseModel> getMyReturns(String projectId);

  Future<InvestmentDistributionsHistoryResponseModel> getDistributions(
    String projectId,
  );

  Future<InvestmentDistributionPreviewResponseModel> previewDistribution({
    required String projectId,
    required double amount,
  });

  Future<InvestmentDistributionResultResponseModel> distribute({
    required String projectId,
    required double amount,
  });
}

class InvestmentReturnsRemoteDataSourceImpl
    implements InvestmentReturnsRemoteDataSource {
  final BaseApiClient apiClient;

  InvestmentReturnsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MyInvestmentReturnsResponseModel> getMyReturns(
    String projectId,
  ) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.projectInvestmentMyReturns(projectId),
    );
    return MyInvestmentReturnsResponseModel.fromJson(
      parseInvestmentReturnsResponseMap(response),
    );
  }

  @override
  Future<InvestmentDistributionsHistoryResponseModel> getDistributions(
    String projectId,
  ) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.projectInvestmentDistributions(projectId),
    );
    return InvestmentDistributionsHistoryResponseModel.fromJson(
      parseInvestmentReturnsResponseMap(response),
    );
  }

  @override
  Future<InvestmentDistributionPreviewResponseModel> previewDistribution({
    required String projectId,
    required double amount,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectInvestmentDistributePreview(projectId),
      data: {'amount': amount},
    );
    return InvestmentDistributionPreviewResponseModel.fromJson(
      parseInvestmentReturnsResponseMap(response),
    );
  }

  @override
  Future<InvestmentDistributionResultResponseModel> distribute({
    required String projectId,
    required double amount,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectInvestmentDistribute(projectId),
      data: {'amount': amount},
    );
    return InvestmentDistributionResultResponseModel.fromJson(
      parseInvestmentReturnsResponseMap(response),
    );
  }
}
