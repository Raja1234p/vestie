import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';

abstract class VotingRemoteDataSource {
  Future<void> requestVoteExtension(
    String projectId,
    int extraDays,
    String reason,
  );

  Future<void> cancelProject(String projectId, String reason);
}

class VotingRemoteDataSourceImpl implements VotingRemoteDataSource {
  final BaseApiClient apiClient;

  VotingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> requestVoteExtension(
    String projectId,
    int extraDays,
    String reason,
  ) async {
    await apiClient.post(
      ApiConstants.projectClosureVotingExtend(projectId),
      data: {'additionalHours': extraDays * 24},
    );
  }

  @override
  Future<void> cancelProject(String projectId, String reason) async {
    await apiClient.post(ApiConstants.projectCancel(projectId));
  }
}
