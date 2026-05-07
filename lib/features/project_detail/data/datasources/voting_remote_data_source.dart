import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';

abstract class VotingRemoteDataSource {
  Future<void> submitVote(String projectId, bool isPositive);
  Future<void> requestVoteExtension(String projectId, int extraDays, String reason);
  Future<void> finalizeVote(String projectId);
  Future<void> cancelProject(String projectId, String reason);
}

class VotingRemoteDataSourceImpl implements VotingRemoteDataSource {
  final BaseApiClient apiClient;

  VotingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> submitVote(String projectId, bool isPositive) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/closure-voting/vote',
      data: {'decision': isPositive ? 'Approve' : 'Reject'},
    );
  }

  @override
  Future<void> requestVoteExtension(String projectId, int extraDays, String reason) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/closure-voting/extend',
      data: {'additionalHours': extraDays * 24},
    );
  }

  @override
  Future<void> finalizeVote(String projectId) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/closure-voting/finalize');
  }

  @override
  Future<void> cancelProject(String projectId, String reason) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/cancel',
    );
  }
}
