import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_announcements/domain/repositories/project_announcements_repository.dart';

import '../datasources/project_announcements_remote_data_source.dart';

class ProjectAnnouncementsRepositoryImpl
    implements ProjectAnnouncementsRepository {
  final ProjectAnnouncementsRemoteDataSource remoteDataSource;

  ProjectAnnouncementsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> create({
    required String projectId,
    required String heading,
    required String content,
  }) async {
    try {
      await remoteDataSource.create(
        projectId: projectId,
        heading: heading,
        content: content,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> delete({
    required String projectId,
    required String announcementId,
  }) async {
    try {
      await remoteDataSource.delete(
        projectId: projectId,
        announcementId: announcementId,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
