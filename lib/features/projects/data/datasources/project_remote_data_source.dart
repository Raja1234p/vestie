import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';
import '../models/project_summary_model.dart';
import '../models/project_detail_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectSummaryModel>> getProjects({required String scope});
  Future<ProjectDetailModel> getProjectDetail(String projectId);
  Future<void> launchProject(String projectId);
  Future<void> completeProject(String projectId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProjectSummaryModel>> getProjects({required String scope}) async {
    final response = await apiClient.get<List<dynamic>>(
      '${ApiConstants.baseUrl}/projects',
      queryParameters: {'scope': scope},
    );
    return response.map((json) => ProjectSummaryModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProjectDetailModel> getProjectDetail(String projectId) async {
    final response = await apiClient.get<Map<String, dynamic>>('${ApiConstants.baseUrl}/projects/$projectId');
    return ProjectDetailModel.fromJson(response);
  }

  @override
  Future<void> launchProject(String projectId) async {
    await apiClient.post('${ApiConstants.baseUrl}/projects/$projectId/launch');
  }

  @override
  Future<void> completeProject(String projectId) async {
    await apiClient.post('${ApiConstants.baseUrl}/projects/$projectId/complete');
  }
}
