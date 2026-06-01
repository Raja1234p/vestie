import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

abstract class ProjectAnnouncementsRemoteDataSource {
  Future<void> create({
    required String projectId,
    required String heading,
    required String content,
  });

  Future<void> delete({
    required String projectId,
    required String announcementId,
  });
}

class ProjectAnnouncementsRemoteDataSourceImpl
    implements ProjectAnnouncementsRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectAnnouncementsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> create({
    required String projectId,
    required String heading,
    required String content,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectAnnouncements(projectId),
      data: {'heading': heading, 'content': content},
    );
  }

  @override
  Future<void> delete({
    required String projectId,
    required String announcementId,
  }) async {
    await apiClient.delete(
      ApiConstants.projectAnnouncement(projectId, announcementId),
    );
  }
}
