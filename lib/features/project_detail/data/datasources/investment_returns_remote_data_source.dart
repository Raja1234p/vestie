import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/pagination_dto.dart';
import '../../../../core/network/base_api_client.dart';
import '../models/investment_returns_response_models.dart';

abstract class InvestmentReturnsRemoteDataSource {
  Future<MyInvestmentReturnsResponseModel> getMyReturns(
    String projectId, {
    int historyPage = PaginationQuery.defaultPage,
    int? historyPageSize,
  });

  Future<InvestmentDistributionsHistoryResponseModel> getDistributions(
    String projectId, {
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

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
    String projectId, {
    int historyPage = PaginationQuery.defaultPage,
    int? historyPageSize,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.projectInvestmentMyReturns(projectId),
      queryParameters: PaginationQuery.historyPage(
        page: historyPage,
        pageSize: historyPageSize,
      ),
    );
    return MyInvestmentReturnsResponseModel.fromJson(
      parseInvestmentReturnsResponseMap(response),
    );
  }

  @override
  Future<InvestmentDistributionsHistoryResponseModel> getDistributions(
    String projectId, {
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.projectInvestmentDistributions(projectId),
      queryParameters: PaginationQuery.pageAndSize(
        page: page,
        pageSize: pageSize,
      ),
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
