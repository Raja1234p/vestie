import 'package:vestie/features/project_detail/domain/entities/project_announcement_attachment_entity.dart';

/// `attachments[]` item on announcement API responses.
class ProjectAnnouncementAttachmentModel {
  final String id;
  final String attachmentUrl;
  final int sortOrder;

  const ProjectAnnouncementAttachmentModel({
    required this.id,
    required this.attachmentUrl,
    required this.sortOrder,
  });

  factory ProjectAnnouncementAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ProjectAnnouncementAttachmentModel(
      id: _string(json['id']),
      attachmentUrl: _string(json['attachmentUrl']),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  ProjectAnnouncementAttachmentEntity toEntity() {
    return ProjectAnnouncementAttachmentEntity(
      id: id,
      attachmentUrl: attachmentUrl,
      sortOrder: sortOrder,
    );
  }

  static List<ProjectAnnouncementAttachmentModel> listFromJson(Object? raw) {
    if (raw is! List) return const [];

    final parsed = <ProjectAnnouncementAttachmentModel>[];
    for (final item in raw) {
      if (item is! Map) continue;
      parsed.add(
        ProjectAnnouncementAttachmentModel.fromJson(
          item.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );
    }

    parsed.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return parsed;
  }

  static String _string(Object? value) => value?.toString().trim() ?? '';
}
