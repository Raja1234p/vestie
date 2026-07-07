import 'package:vestie/features/project_detail/domain/entities/project_announcement_entity.dart';

import 'project_announcement_attachment_model.dart';

/// Announcement payload from `POST /projects/{id}/announcements` (and detail list items).
class ProjectAnnouncementResponseModel {
  final String id;
  final String heading;
  final String content;
  final String? createdAtUtc;
  final List<ProjectAnnouncementAttachmentModel> attachments;

  const ProjectAnnouncementResponseModel({
    required this.id,
    required this.heading,
    required this.content,
    this.createdAtUtc,
    this.attachments = const [],
  });

  factory ProjectAnnouncementResponseModel.fromJson(Map<String, dynamic> json) {
    return ProjectAnnouncementResponseModel(
      id: _string(json['id']),
      heading: _string(json['heading']),
      content: _string(json['content']),
      createdAtUtc:
          _nullableString(json['createdAtUtc']) ??
          _nullableString(json['createdUtc']),
      attachments: ProjectAnnouncementAttachmentModel.listFromJson(
        json['attachments'],
      ),
    );
  }

  ProjectAnnouncementEntity toEntity() {
    return ProjectAnnouncementEntity(
      id: id,
      heading: heading,
      content: content,
      createdAtUtc: createdAtUtc,
      attachments: attachments
          .map((attachment) => attachment.toEntity())
          .toList(growable: false),
    );
  }

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final trimmed = value?.toString().trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
