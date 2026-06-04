import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response_body.dart';
import '../../../../core/network/base_api_client.dart';
import 'join_project_request_body.dart';
import '../models/invite_preview_model.dart';
import '../models/join_project_result_model.dart';
import '../models/project_summary_model.dart';
import '../models/project_detail_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectSummaryModel>> getProjects({required String scope});
  Future<ProjectDetailModel> getProjectDetail(String projectId);
  Future<void> launchProject(String projectId);
  Future<void> completeProject(String projectId);
  Future<InvitePreviewModel> previewInvite(String inviteCode);
  /// Exactly one of [projectId] (public discover join) or [inviteCode] (invite link).
  Future<JoinProjectResultModel> joinProject({
    String? projectId,
    String? inviteCode,
  });
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProjectSummaryModel>> getProjects({required String scope}) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiConstants.projects,
      queryParameters: {'scope': scope},
    );
    return response.map((json) => ProjectSummaryModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ProjectDetailModel> getProjectDetail(String projectId) async {
    final response = await apiClient.get<Map<String, dynamic>>('${ApiConstants.projects}/$projectId');
    return ProjectDetailModel.fromJson(response);
  }

  @override
  Future<void> launchProject(String projectId) async {
    await apiClient.post(ApiConstants.projectLaunch(projectId));
  }

  @override
  Future<void> completeProject(String projectId) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/complete');
  }

  @override
  Future<InvitePreviewModel> previewInvite(String inviteCode) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.projects}/invites/$inviteCode/preview',
    );
    return InvitePreviewModel.fromJson(unwrapApiResponseBody(response));
  }

  @override
  Future<JoinProjectResultModel> joinProject({
    String? projectId,
    String? inviteCode,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.projects}/join',
      data: buildJoinProjectRequestBody(
        projectId: projectId,
        inviteCode: inviteCode,
      ),
    );
    return JoinProjectResultModel.fromJson(unwrapApiResponseBody(response));
  }
}
