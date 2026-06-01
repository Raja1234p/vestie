import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/project_announcement_entity.dart';
import 'announcement_card.dart';

/// Renders project announcements from the API (newest first).
class ProjectAnnouncementsSection extends StatelessWidget {
  final List<ProjectAnnouncementEntity> announcements;
  final bool canDeleteAnnouncement;
  final Future<void> Function(String announcementId)? onDeleteAnnouncement;

  const ProjectAnnouncementsSection({
    super.key,
    required this.announcements,
    this.canDeleteAnnouncement = false,
    this.onDeleteAnnouncement,
  });

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return const AnnouncementCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < announcements.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          AnnouncementCard(
            announcementId: announcements[i].id,
            heading: announcements[i].heading,
            text: announcements[i].content,
            canDeleteAnnouncement: canDeleteAnnouncement,
            onDelete: canDeleteAnnouncement && onDeleteAnnouncement != null
                ? () => onDeleteAnnouncement!(announcements[i].id)
                : null,
          ),
        ],
      ],
    );
  }
}
