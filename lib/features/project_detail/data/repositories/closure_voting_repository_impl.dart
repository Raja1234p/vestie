import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/closure_vote_entities.dart';
import '../../domain/repositories/closure_voting_repository.dart';
import '../datasources/closure_voting_remote_data_source.dart';
import 'closure_voting_failure_mapper.dart';

class ClosureVotingRepositoryImpl implements ClosureVotingRepository {
  final ClosureVotingRemoteDataSource remoteDataSource;

  ClosureVotingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OpenClosureVoteEntity>> openClosureVoting({
    required String projectId,
    required int votingWindowDays,
    required ClosureVoteType voteType,
  }) async {
    return _execute(
      () async {
        final model = await remoteDataSource.open(
          projectId: projectId,
          votingWindowDays: votingWindowDays,
          voteType: voteType,
        );
        return model.toEntity();
      },
    );
  }

  @override
  Future<Either<Failure, CastClosureVoteResultEntity>> castClosureVote({
    required String projectId,
    required bool voteForSuccess,
  }) async {
    return _execute(
      () async {
        final model = await remoteDataSource.cast(
          projectId: projectId,
          voteForSuccess: voteForSuccess,
        );
        return model.toEntity();
      },
    );
  }

  @override
  Future<Either<Failure, ActiveClosureVoteEntity?>> getActiveClosureVote(
    String projectId,
  ) async {
    try {
      final model = await remoteDataSource.getActive(projectId);
      return Right(model?.toEntity());
    } on Failure catch (f) {
      return Left(ClosureVotingFailureMapper.map(f));
    } catch (e) {
      return Left(ClosureVotingFailureMapper.map(FailureMapper.fromException(e)));
    }
  }

  @override
  Future<Either<Failure, CancelClosureVoteResultEntity>> cancelClosureVote({
    required String projectId,
  }) {
    return _execute(
      () async {
        final model = await remoteDataSource.cancel(projectId: projectId);
        final entity = model.toEntity();
        if (!entity.cancelled) {
          throw const ServerFailure(AppStrings.errorGeneric);
        }
        return entity;
      },
      mapFailure: ClosureVotingFailureMapper.mapCancel,
    );
  }

  Future<Either<Failure, T>> _execute<T>(
    Future<T> Function() action, {
    Failure Function(Failure failure)? mapFailure,
  }) async {
    final mapper = mapFailure ?? ClosureVotingFailureMapper.map;
    try {
      final result = await action();
      return Right(result);
    } on Failure catch (f) {
      return Left(mapper(f));
    } catch (e) {
      return Left(mapper(FailureMapper.fromException(e)));
    }
  }
}
