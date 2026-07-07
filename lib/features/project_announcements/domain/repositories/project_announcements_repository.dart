import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';

abstract class ProjectAnnouncementsRepository {
  Future<Either<Failure, void>> create({
    required String projectId,
    required String heading,
    required String content,
    List<String> attachmentPaths = const [],
  });

  Future<Either<Failure, void>> delete({
    required String projectId,
    required String announcementId,
  });
}
