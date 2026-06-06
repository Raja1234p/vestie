import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_api_client.dart';

import '../models/member_activity_response_model.dart';
import '../models/pending_membership_model.dart';

abstract class ProjectActionsRemoteDataSource {
  /// Week 3 — `GET /projects/{id}/memberships/pending`
  Future<List<PendingMembershipModel>> listPendingJoinRequests(
    String projectId,
  );

  /// `GET /projects/{projectId}/members/{userId}/activity`
  Future<MemberActivityResponseModel> getMemberActivity({
    required String projectId,
    required String userId,
    required String projectName,
  });

  Future<void> approveJoinRequest(String projectId, String membershipId);
  Future<void> rejectJoinRequest(String projectId, String membershipId);
  Future<void> removeMember(String projectId, String userId);
  Future<void> promoteToCoLeader(String projectId, String userId);
  Future<void> demoteCoLeader(String projectId, String userId);
  Future<void> openClosureVoting({
    required String projectId,
    required int votingWindowDays,
  });
  Future<void> openStopContributionsVoting({
    required String projectId,
    required int votingWindowDays,
  });
  Future<void> cancelProject({required String projectId});
  Future<void> leaveProject({required String projectId});
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

class ProjectActionsRemoteDataSourceImpl
    implements ProjectActionsRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectActionsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PendingMembershipModel>> listPendingJoinRequests(
    String projectId,
  ) async {
    final response = await apiClient.get<List<dynamic>>(
      '${ApiConstants.projects}/$projectId/memberships/pending',
    );
    return response
        .whereType<Map>()
        .map((m) => PendingMembershipModel.fromJson(m.cast<String, dynamic>()))
        .toList(growable: false);
  }

  @override
  Future<MemberActivityResponseModel> getMemberActivity({
    required String projectId,
    required String userId,
    required String projectName,
  }) async {
    final response = await apiClient.get<dynamic>(
      ApiConstants.projectMemberActivity(projectId, userId),
    );
    final map = _unwrapActivityPayload(response);
    return MemberActivityResponseModel.fromJson(map, projectName: projectName);
  }

  @override
  Future<void> approveJoinRequest(String projectId, String membershipId) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/memberships/$membershipId/approve',
    );
  }

  @override
  Future<void> rejectJoinRequest(String projectId, String membershipId) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/memberships/$membershipId/reject',
    );
  }

  @override
  Future<void> removeMember(String projectId, String userId) async {
    await apiClient.delete(
      '${ApiConstants.projects}/$projectId/members/$userId',
    );
  }

  @override
  Future<void> promoteToCoLeader(String projectId, String userId) async {
    await apiClient.post(ApiConstants.projectMemberCoLeader(projectId, userId));
  }

  @override
  Future<void> demoteCoLeader(String projectId, String userId) async {
    await apiClient.delete(
      ApiConstants.projectMemberCoLeader(projectId, userId),
    );
  }

  @override
  Future<void> openClosureVoting({
    required String projectId,
    required int votingWindowDays,
  }) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/closure-voting/open',
      data: {'successVoteWindowHours': votingWindowDays * 24},
    );
  }

  @override
  Future<void> openStopContributionsVoting({
    required String projectId,
    required int votingWindowDays,
  }) async {
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/contributions/stop-voting/open',
      data: {'stopContributionsVoteWindowHours': votingWindowDays * 24},
    );
  }

  @override
  Future<void> cancelProject({required String projectId}) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/cancel');
  }

  @override
  Future<void> leaveProject({required String projectId}) async {
    await apiClient.post('${ApiConstants.projects}/$projectId/members/leave');
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
    final url =
        (response['inviteUrl'] ?? response['shareUrl'] ?? response['url'] ?? '')
            .toString()
            .trim();
    if (url.isNotEmpty) return url;

    return (response['inviteCode'] ?? response['code'] ?? '').toString();
  }

  @override
  Future<void> markDefaulted({
    required String projectId,
    required String userId,
  }) async {
    await apiClient.post(
      ApiConstants.projectMemberDefaulted(projectId, userId),
    );
  }

  @override
  Future<void> removeForNonRepayment({
    required String projectId,
    required String userId,
  }) async {
    await apiClient.post(
      ApiConstants.projectMemberRemoveNonRepayment(projectId, userId),
    );
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
    await apiClient.post(
      '${ApiConstants.projects}/$projectId/closure-voting/finalize',
    );
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

/// Supports flat activity JSON or `{ "data": { … } }` envelopes.
Map<String, dynamic> _unwrapActivityPayload(dynamic response) {
  if (response is! Map) return <String, dynamic>{};
  final map = response.cast<String, dynamic>();
  final data = map['data'];
  if (data is Map) {
    final inner = data.cast<String, dynamic>();
    if (inner.containsKey('memberId') ||
        inner.containsKey('summary') ||
        inner.containsKey('transactions')) {
      return inner;
    }
  }
  return map;
}
