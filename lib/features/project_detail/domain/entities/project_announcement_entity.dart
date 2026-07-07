import 'package:equatable/equatable.dart';

import 'project_announcement_attachment_entity.dart';

/// Leader announcement on a project (`GET /projects/{id}` → `announcements[]`).
class ProjectAnnouncementEntity extends Equatable {
  final String id;
  final String heading;
  final String content;
  final String? createdAtUtc;
  final List<ProjectAnnouncementAttachmentEntity> attachments;

  const ProjectAnnouncementEntity({
    required this.id,
    required this.heading,
    required this.content,
    this.createdAtUtc,
    this.attachments = const [],
  });

  String get displayText {
    final h = heading.trim();
    final c = content.trim();
    if (h.isEmpty) return c;
    if (c.isEmpty) return h;
    return '$h\n$c';
  }

  /// Non-empty `attachmentUrl` values, preserving API `sortOrder`.
  List<String> get attachmentImageUrls {
    return attachments
        .map((attachment) => attachment.attachmentUrl.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  bool get hasAttachmentImages => attachmentImageUrls.isNotEmpty;

  @override
  List<Object?> get props => [id, heading, content, createdAtUtc, attachments];
}
