import 'package:dartz/dartz.dart';

import 'package:dio/dio.dart';

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
    } on DioException catch (e, stack) {
      AppLogger.error('ProjectDetail Dio Error', error: e, stackTrace: stack);
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return const Left(NetworkFailure());
      }
      if (e.response?.statusCode == 404) {
        return const Left(ServerFailure('Project not found'));
      }
      if (e.response?.statusCode == 403) {
        return const Left(ForbiddenFailure());
      }
      return const Left(ServerFailure('Failed to load project'));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error('ProjectDetail Unauthorized', error: e, stackTrace: stack);
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error('ProjectDetail Server Exception', error: e, stackTrace: stack);
      final msg = e.message.toLowerCase();
      if (msg.contains('network') || msg.contains('connection') || msg.contains('socket')) {
        return const Left(NetworkFailure());
      }
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error('ProjectDetail Unexpected Exception', error: e, stackTrace: stack);
      return const Left(ServerFailure('Failed to load project'));
    }
  }
}

