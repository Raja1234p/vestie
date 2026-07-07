import 'package:equatable/equatable.dart';

/// One project gallery image from `GET /projects` or `GET /projects/{id}`.
class ProjectImageEntity extends Equatable {
  final String id;
  final String imageUrl;
  final int sortOrder;

  const ProjectImageEntity({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, imageUrl, sortOrder];
}
