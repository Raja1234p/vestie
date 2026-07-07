import 'package:equatable/equatable.dart';

/// Announcement file from `attachments[]` on project announcements API.
class ProjectAnnouncementAttachmentEntity extends Equatable {
  final String id;
  final String attachmentUrl;
  final int sortOrder;

  const ProjectAnnouncementAttachmentEntity({
    required this.id,
    required this.attachmentUrl,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, attachmentUrl, sortOrder];
}
