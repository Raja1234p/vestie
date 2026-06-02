import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/project_announcement_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'announcement_card.dart';

/// Project announcements from `GET /projects/{id}` → `announcements[]`.
///
/// Visible to every member when the list is non-empty. Swipe-to-delete is only
/// enabled for [ProjectDetailEntity.isModeratorView] (GroupLeader / CoLeader).
class ProjectAnnouncementsSection extends StatefulWidget {
  final ProjectDetailEntity project;

  /// Returns `true` when the API delete succeeded.
  final Future<bool> Function(String announcementId)? onDeleteAnnouncement;

  const ProjectAnnouncementsSection({
    super.key,
    required this.project,
    this.onDeleteAnnouncement,
  });

  @override
  State<ProjectAnnouncementsSection> createState() =>
      _ProjectAnnouncementsSectionState();
}

class _ProjectAnnouncementsSectionState extends State<ProjectAnnouncementsSection> {
  late List<ProjectAnnouncementEntity> _visible;

  bool get _canDelete => widget.project.isModeratorView;

  @override
  void initState() {
    super.initState();
    _syncFromProject();
  }

  @override
  void didUpdateWidget(covariant ProjectAnnouncementsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.announcements != widget.project.announcements) {
      _syncFromProject();
    }
  }

  void _syncFromProject() {
    _visible = List<ProjectAnnouncementEntity>.from(
      widget.project.announcements,
    );
  }

  void _onDismissed(String id) {
    final index = _visible.indexWhere((a) => a.id == id);
    if (index < 0) return;

    final removed = _visible[index];
    setState(() => _visible.removeAt(index));

    final delete = widget.onDeleteAnnouncement;
    if (delete == null) return;

    delete(id).then((ok) {
      if (!mounted || ok) return;
      setState(() {
        final insertAt = index.clamp(0, _visible.length);
        _visible.insert(insertAt, removed);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _visible.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          AnnouncementCard(
            announcementId: _visible[i].id,
            heading: _visible[i].heading,
            text: _visible[i].content,
            canDeleteAnnouncement: _canDelete,
            onDelete: _canDelete && widget.onDeleteAnnouncement != null
                ? () => _onDismissed(_visible[i].id)
                : null,
          ),
        ],
      ],
    );
  }
}
