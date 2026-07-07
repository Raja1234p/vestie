import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/create_announcement_multipart_builder.dart';

abstract class ProjectAnnouncementsRemoteDataSource {
  Future<void> create({
    required String projectId,
    required String heading,
    required String content,
    List<String> attachmentPaths = const [],
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
    List<String> attachmentPaths = const [],
  }) async {
    final formData = await CreateAnnouncementMultipartBuilder.build(
      heading: heading,
      content: content,
      attachmentPaths: attachmentPaths,
    );
    await apiClient.post<Map<String, dynamic>>(
      ApiConstants.projectAnnouncements(projectId),
      data: formData,
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
