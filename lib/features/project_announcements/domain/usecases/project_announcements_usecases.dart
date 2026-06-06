import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/project_announcements_repository.dart';

class CreateProjectAnnouncementUseCase {
  final ProjectAnnouncementsRepository repository;

  CreateProjectAnnouncementUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String heading,
    required String content,
  }) => repository.create(
    projectId: projectId,
    heading: heading,
    content: content,
  );
}

class DeleteProjectAnnouncementUseCase {
  final ProjectAnnouncementsRepository repository;

  DeleteProjectAnnouncementUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String announcementId,
  }) => repository.delete(projectId: projectId, announcementId: announcementId);
}
