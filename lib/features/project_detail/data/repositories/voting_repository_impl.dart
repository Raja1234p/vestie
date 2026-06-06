import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/voting_repository.dart';
import '../datasources/voting_remote_data_source.dart';

class VotingRepositoryImpl implements VotingRepository {
  final VotingRemoteDataSource remoteDataSource;

  VotingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> submitVote(
    String projectId,
    bool isPositive,
  ) async {
    return _execute(() => remoteDataSource.submitVote(projectId, isPositive));
  }

  @override
  Future<Either<Failure, void>> requestVoteExtension(
    String projectId,
    int extraDays,
    String reason,
  ) async {
    return _execute(
      () => remoteDataSource.requestVoteExtension(projectId, extraDays, reason),
    );
  }

  @override
  Future<Either<Failure, void>> finalizeVote(String projectId) async {
    return _execute(() => remoteDataSource.finalizeVote(projectId));
  }

  @override
  Future<Either<Failure, void>> cancelProject(
    String projectId,
    String reason,
  ) async {
    return _execute(() => remoteDataSource.cancelProject(projectId, reason));
  }

  Future<Either<Failure, void>> _execute(Future<void> Function() action) async {
    try {
      await action();
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
