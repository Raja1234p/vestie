import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/models/pagination_dto.dart';
import '../../../../../core/network/base_api_client.dart';

import '../models/vff_connection_model.dart';
import '../models/vff_inbox_model.dart';
import '../models/vff_json_parsing.dart';
import '../models/vff_profile_model.dart';

abstract class VffRemoteDataSource {
  Future<PaginatedListModel<VffConnectionModel>> listMyVffs({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<VffConnectedProfileModel> getConnectedProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  });

  Future<VffPublicProfileModel> getPublicProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  });

  Future<VffRemoveConnectionResultModel> removeConnection(String userId);

  Future<VffReceivedInboxModel> getReceivedInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
  });

  Future<VffSentInboxModel> getSentInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
    int joinRequestsPage = PaginationQuery.defaultPage,
    int? joinRequestsPageSize,
  });

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
  Future<PaginatedListModel<VffConnectionModel>> listMyVffs({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    final response = await apiClient.get<dynamic>(
      ApiConstants.userMeVffs,
      queryParameters: PaginationQuery.pageAndSize(
        page: page,
        pageSize: pageSize,
      ),
    );
    final maps = VffJsonParsing.parseObjectList(response);
    final pagination = PaginatedListParser.parsePagination(
      response,
      fallbackItemCount: maps.length,
    );
    return PaginatedListModel(
      items: maps.map(VffConnectionModel.fromJson).toList(growable: false),
      pagination: pagination,
    );
  }

  @override
  Future<VffConnectedProfileModel> getConnectedProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userMeVffProfile(userId),
      queryParameters: PaginationQuery.projectsPage(
        page: projectsPage,
        pageSize: projectsPageSize,
      ),
    );
    return VffConnectedProfileModel.fromJson(response);
  }

  @override
  Future<VffPublicProfileModel> getPublicProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userVffPublicProfile(userId),
      queryParameters: PaginationQuery.projectsPage(
        page: projectsPage,
        pageSize: projectsPageSize,
      ),
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
  Future<VffReceivedInboxModel> getReceivedInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userInboxReceived,
      queryParameters: PaginationQuery.inboxReceived(
        vffRequestsPage: vffRequestsPage,
        vffRequestsPageSize: vffRequestsPageSize,
        projectInvitesPage: projectInvitesPage,
        projectInvitesPageSize: projectInvitesPageSize,
      ),
    );
    return VffReceivedInboxModel.fromJson(response);
  }

  @override
  Future<VffSentInboxModel> getSentInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
    int joinRequestsPage = PaginationQuery.defaultPage,
    int? joinRequestsPageSize,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.userInboxSent,
      queryParameters: PaginationQuery.inboxSent(
        vffRequestsPage: vffRequestsPage,
        vffRequestsPageSize: vffRequestsPageSize,
        projectInvitesPage: projectInvitesPage,
        projectInvitesPageSize: projectInvitesPageSize,
        joinRequestsPage: joinRequestsPage,
        joinRequestsPageSize: joinRequestsPageSize,
      ),
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
