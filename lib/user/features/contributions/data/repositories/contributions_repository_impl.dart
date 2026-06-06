import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/utils/logger.dart';
import '../datasources/contributions_remote_data_source.dart';
import '../../domain/repositories/contributions_repository.dart';
import '../../domain/value_objects/contribution_flow_models.dart';

class ContributionsRepositoryImpl implements ContributionsRepository {
  final ContributionsRemoteDataSource _remote;

  ContributionsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ContributionConfig>> getConfig({
    required String projectId,
  }) async {
    try {
      final model = await _remote.getConfig(projectId: projectId);
      return Right(ContributionConfig.fromModel(model));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error(
        'ContributionConfig Unauthorized',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'ContributionConfig Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'ContributionConfig Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to load contribution config'));
    }
  }

  @override
  Future<Either<Failure, ContributionPreview>> preview({
    required ContributionInput input,
  }) async {
    try {
      final model = await _remote.preview(request: input.toRequest());
      return Right(ContributionPreview.fromModel(model));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error(
        'ContributionPreview Unauthorized',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'ContributionPreview Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'ContributionPreview Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to preview contribution'));
    }
  }

  @override
  Future<Either<Failure, ContributionResult>> confirm({
    required ContributionInput input,
  }) async {
    try {
      final model = await _remote.confirm(request: input.toRequest());
      return Right(ContributionResult.fromModel(model));
    } on UnauthorizedException catch (e, stack) {
      AppLogger.error(
        'ContributionConfirm Unauthorized',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } on ServerException catch (e, stack) {
      AppLogger.error(
        'ContributionConfirm Server Exception',
        error: e,
        stackTrace: stack,
      );
      return Left(ServerFailure(e.message, e.title));
    } catch (e, stack) {
      AppLogger.error(
        'ContributionConfirm Unexpected Exception',
        error: e,
        stackTrace: stack,
      );
      return const Left(ServerFailure('Failed to confirm contribution'));
    }
  }
}
