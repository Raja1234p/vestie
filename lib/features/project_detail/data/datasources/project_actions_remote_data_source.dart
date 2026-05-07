import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';

abstract class ProjectActionsRemoteDataSource {
  Future<void> approveJoinRequest(String projectId, String userId);
  Future<void> rejectJoinRequest(String projectId, String userId);
  Future<void> removeMember(String projectId, String userId);
  Future<void> promoteToCoLeader(String projectId, String userId);
  Future<void> demoteCoLeader(String projectId, String userId);
  Future<void> openClosureVoting({required String projectId});
  Future<void> cancelProject({required String projectId});
  Future<String> createInvite({
    required String projectId,
    required bool requiresApproval,
    required int expiresInDays,
    required int maxUses,
  });
  Future<void> markDefaulted({
    required String projectId,
    required String userId,
  });
  Future<void> removeForNonRepayment({
    required String projectId,
    required String userId,
  });
  Future<void> castClosureVote({
    required String projectId,
    required bool voteForSuccess,
  });
  Future<void> extendClosureVoting({
    required String projectId,
    required int extraDays,
  });
  Future<void> finalizeClosureVoting({required String projectId});
  Future<void> resolveGoal({required String projectId});
  Future<void> extendDeadline({
    required String projectId,
    required int extraDays,
  });
  Future<void> completeProject({required String projectId});
}

class ProjectActionsRemoteDataSourceImpl implements ProjectActionsRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectActionsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> approveJoinRequest(String projectId, String userId) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/memberships/$userId/approve');
  }

  @override
  Future<void> rejectJoinRequest(String projectId, String userId) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/memberships/$userId/reject');
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {
    await apiClient.delete('${ApiConstants.projects}/$projectId/members/$userId');
  }

  @override
  Future<void> promoteToCoLeader(String projectId, String userId) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/members/$userId/co-leader');
  }

  @override
  Future<void> demoteCoLeader(String projectId, String userId) async {
    await apiClient.delete('${ApiConstants.projects}/$projectId/members/$userId/co-leader');
  }

  @override
  Future<void> openClosureVoting({required String projectId}) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/closure-voting/open');
  }

  @override
  Future<void> cancelProject({required String projectId}) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/cancel');
  }

  @override
  Future<String> createInvite({
    required String projectId,
    required bool requiresApproval,
    required int expiresInDays,
    required int maxUses,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.projects}/$projectId/invites',
      data: {
        'requiresApproval': requiresApproval,
        'expiresInDays': expiresInDays,
        'maxUses': maxUses,
      },
    );
    return (response['inviteCode'] ?? response['code'] ?? '').toString();
  }

  @override
  Future<void> markDefaulted({
    required String projectId,
    required String userId,
  }) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/members/$userId/defaulted');
  }

  @override
  Future<void> removeForNonRepayment({
    required String projectId,
    required String userId,
  }) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/members/$userId/remove-non-repayment');
  }

  @override
  Future<void> castClosureVote({
    required String projectId,
    required bool voteForSuccess,
  }) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/closure-voting/vote',
      data: {'decision': voteForSuccess ? 'Approve' : 'Reject'},
    );
  }

  @override
  Future<void> extendClosureVoting({
    required String projectId,
    required int extraDays,
  }) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/closure-voting/extend',
      data: {'additionalHours': extraDays * 24},
    );
  }

  @override
  Future<void> finalizeClosureVoting({required String projectId}) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/closure-voting/finalize');
  }

  @override
  Future<void> resolveGoal({required String projectId}) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/goal/resolve');
  }

  @override
  Future<void> extendDeadline({
    required String projectId,
    required int extraDays,
  }) async {
    final newEndsAtUtc = DateTime.now()
        .toUtc()
        .add(Duration(days: extraDays))
        .toIso8601String();
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/deadline/extend',
      data: {'newEndsAtUtc': newEndsAtUtc},
    );
  }

  @override
  Future<void> completeProject({required String projectId}) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/complete');
  }
}
