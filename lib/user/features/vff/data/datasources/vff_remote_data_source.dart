import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/base_api_client.dart';

import '../models/vff_connection_model.dart';
import '../models/vff_inbox_model.dart';
import '../models/vff_profile_model.dart';

abstract class VffRemoteDataSource {
  Future<List<VffConnectionModel>> listMyVffs();

  Future<VffConnectedProfileModel> getConnectedProfile(String userId);

  Future<VffPublicProfileModel> getPublicProfile(String userId);

  Future<VffRemoveConnectionResultModel> removeConnection(String userId);

  Future<VffReceivedInboxModel> getReceivedInbox();

  Future<VffSentInboxModel> getSentInbox();

  Future<VffSendRequestResultModel> sendVffRequest({
    required String projectId,
    required String userId,
  });

  Future<VffInboxRequestModel> acceptVffRequest(String requestId);

  Future<VffInboxRequestModel> declineVffRequest(String requestId);

  Future<List<VffInviteResultModel>> inviteVffsToProject({
    required String projectId,
    required List<String> userIds,
  });

  Future<VffInviteResultModel> acceptProjectInvite({
    required String projectId,
    required String inviteId,
  });

  Future<VffInviteResultModel> declineProjectInvite({
    required String projectId,
    required String inviteId,
  });

  Future<VffJoinFromVffResultModel> joinFromVffProfile({
    required String projectId,
  });
}

class VffRemoteDataSourceImpl implements VffRemoteDataSource {
  final BaseApiClient apiClient;

  VffRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<VffConnectionModel>> listMyVffs() async {
    final response = await apiClient.get<List<dynamic>>(ApiConstants.userMeVffs);
    return response
        .whereType<Map>()
        .map((m) => VffConnectionModel.fromJson(m.cast<String, dynamic>()))
        .toList(growable: false);
  }

  @override
  Future<VffConnectedProfileModel> getConnectedProfile(String userId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userMeVffProfile(userId),
    );
    return VffConnectedProfileModel.fromJson(response);
  }

  @override
  Future<VffPublicProfileModel> getPublicProfile(String userId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userVffPublicProfile(userId),
    );
    return VffPublicProfileModel.fromJson(response);
  }

  @override
  Future<VffRemoveConnectionResultModel> removeConnection(String userId) async {
    final response = await apiClient.delete<dynamic>(
      ApiConstants.userVffConnection(userId),
    );
    final map = switch (response) {
      final Map m => m.cast<String, dynamic>(),
      _ => <String, dynamic>{'success': true, 'message': ''},
    };
    return VffRemoveConnectionResultModel.fromJson(map);
  }

  @override
  Future<VffReceivedInboxModel> getReceivedInbox() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userInboxReceived,
    );
    return VffReceivedInboxModel.fromJson(response);
  }

  @override
  Future<VffSentInboxModel> getSentInbox() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userInboxSent,
    );
    return VffSentInboxModel.fromJson(response);
  }

  @override
  Future<VffSendRequestResultModel> sendVffRequest({
    required String projectId,
    required String userId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectMemberVffRequest(projectId, userId),
    );
    return VffSendRequestResultModel.fromJson(response);
  }

  @override
  Future<VffInboxRequestModel> acceptVffRequest(String requestId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.userVffRequestAccept(requestId),
    );
    return VffInboxRequestModel.fromJson(response);
  }

  @override
  Future<VffInboxRequestModel> declineVffRequest(String requestId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.userVffRequestDecline(requestId),
    );
    return VffInboxRequestModel.fromJson(response);
  }

  @override
  Future<List<VffInviteResultModel>> inviteVffsToProject({
    required String projectId,
    required List<String> userIds,
  }) async {
    final response = await apiClient.post<List<dynamic>>(
      ApiConstants.projectVffInvites(projectId),
      data: {'userIds': userIds},
    );
    return response
        .whereType<Map>()
        .map((m) => VffInviteResultModel.fromJson(m.cast<String, dynamic>()))
        .toList(growable: false);
  }

  @override
  Future<VffInviteResultModel> acceptProjectInvite({
    required String projectId,
    required String inviteId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectVffInviteAccept(projectId, inviteId),
    );
    return VffInviteResultModel.fromJson(response);
  }

  @override
  Future<VffInviteResultModel> declineProjectInvite({
    required String projectId,
    required String inviteId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectVffInviteDecline(projectId, inviteId),
    );
    return VffInviteResultModel.fromJson(response);
  }

  @override
  Future<VffJoinFromVffResultModel> joinFromVffProfile({
    required String projectId,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectJoinFromVff(projectId),
    );
    return VffJoinFromVffResultModel.fromJson(response);
  }
}
