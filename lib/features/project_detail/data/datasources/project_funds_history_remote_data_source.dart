import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/pagination_dto.dart';
import '../../../../core/network/base_api_client.dart';
import '../models/project_funds_history_response_model.dart';

abstract class ProjectFundsHistoryRemoteDataSource {
  Future<ProjectFundsHistoryResponseModel> getFundsHistory({
    required String projectId,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });
}

class ProjectFundsHistoryRemoteDataSourceImpl
    implements ProjectFundsHistoryRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectFundsHistoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProjectFundsHistoryResponseModel> getFundsHistory({
    required String projectId,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    final response = await apiClient.get<dynamic>(
      ApiConstants.projectFundsHistory(projectId),
      queryParameters: PaginationQuery.pageAndSize(page: page, pageSize: pageSize),
    );
    return ProjectFundsHistoryResponseModel.fromJson(_asStringKeyedMap(response));
  }

  Map<String, dynamic> _asStringKeyedMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return const <String, dynamic>{};
  }
}
