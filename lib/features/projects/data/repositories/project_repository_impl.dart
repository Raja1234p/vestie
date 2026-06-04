import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/invite_preview_entity.dart';
import '../../domain/entities/join_project_result_entity.dart';
import '../../domain/entities/project_summary_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';
import '../datasources/project_local_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final ProjectLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ProjectSummaryEntity>>> getProjects({required String scope}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProjects = await remoteDataSource.getProjects(scope: scope);
        await localDataSource.cacheProjects(scope, remoteProjects);
        return Right(remoteProjects);
      } on Failure catch (f) {
        return Left(f);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final localProjects = await localDataSource.getCachedProjects(scope);
        return Right(localProjects);
      } on Failure catch (f) {
        return Left(f); // CacheFailure
      }
    }
  }

  @override
  Future<Either<Failure, ProjectDetailEntity>> getProjectDetail(String projectId) async {
    if (await networkInfo.isConnected) {
      try {
        final detail = await remoteDataSource.getProjectDetail(projectId);
        return Right(detail);
      } on Failure catch (f) {
        return Left(f);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> launchProject(String projectId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.launchProject(projectId);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeProject(String projectId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await remoteDataSource.completeProject(projectId);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvitePreviewEntity>> previewInvite(String inviteCode) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final preview = await remoteDataSource.previewInvite(inviteCode);
      return Right(preview);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JoinProjectResultEntity>> joinProject({
    String? projectId,
    String? inviteCode,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await remoteDataSource.joinProject(
        projectId: projectId,
        inviteCode: inviteCode,
      );
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
