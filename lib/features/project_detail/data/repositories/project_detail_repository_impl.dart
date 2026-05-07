import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/repositories/project_detail_repository.dart';
import '../datasources/project_detail_remote_data_source.dart';

class ProjectDetailRepositoryImpl implements ProjectDetailRepository {
  final ProjectDetailRemoteDataSource _remote;

  ProjectDetailRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ProjectDetailEntity>> getProjectDetail({
    required String projectId,
  }) async {
    try {
      final model = await _remote.getProjectDetail(projectId: projectId);
      return Right(model.toEntity());
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('ProjectDetail Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('ProjectDetail Server Exception', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('ProjectDetail Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('Failed to load project'));
    }
  }
}

