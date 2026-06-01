import 'package:equatable/equatable.dart';

/// Leader announcement on a project (`GET /projects/{id}` → `announcements[]`).
class ProjectAnnouncementEntity extends Equatable {
  final String id;
  final String heading;
  final String content;
  final String? createdAtUtc;

  const ProjectAnnouncementEntity({
    required this.id,
    required this.heading,
    required this.content,
    this.createdAtUtc,
  });

  String get displayText {
    final h = heading.trim();
    final c = content.trim();
    if (h.isEmpty) return c;
    if (c.isEmpty) return h;
    return '$h\n$c';
  }

  @override
  List<Object?> get props => [id, heading, content, createdAtUtc];
}
