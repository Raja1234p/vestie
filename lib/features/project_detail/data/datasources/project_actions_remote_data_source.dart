import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';

abstract class ProjectActionsRemoteDataSource {
  Future<void> approveJoinRequest(String projectId, String userId);
  Future<void> rejectJoinRequest(String projectId, String userId);
  Future<void> removeMember(String projectId, String userId);
  Future<void> promoteToCoLeader(String projectId, String userId);
  Future<void> demoteCoLeader(String projectId, String userId);
}

class ProjectActionsRemoteDataSourceImpl implements ProjectActionsRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectActionsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> approveJoinRequest(String projectId, String userId) async {
    await apiClient.post('${ApiConstants.baseUrl}/projects/$projectId/memberships/$userId/approve');
  }

  @override
  Future<void> rejectJoinRequest(String projectId, String userId) async {
    await apiClient.post('${ApiConstants.baseUrl}/projects/$projectId/memberships/$userId/reject');
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {
    await apiClient.delete('${ApiConstants.baseUrl}/projects/$projectId/members/$userId');
  }

  @override
  Future<void> promoteToCoLeader(String projectId, String userId) async {
    await apiClient.post('${ApiConstants.baseUrl}/projects/$projectId/members/$userId/co-leader');
  }

  @override
  Future<void> demoteCoLeader(String projectId, String userId) async {
    await apiClient.delete('${ApiConstants.baseUrl}/projects/$projectId/members/$userId/co-leader');
  }
}
