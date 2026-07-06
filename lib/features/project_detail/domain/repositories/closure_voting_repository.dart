import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/closure_vote_entities.dart';

/// Week 10 project closure voting (`/projects/{id}/closure-voting/*`).
abstract class ClosureVotingRepository {
  Future<Either<Failure, OpenClosureVoteEntity>> openClosureVoting({
    required String projectId,
    required int votingWindowDays,
    required ClosureVoteType voteType,
  });

  Future<Either<Failure, CastClosureVoteResultEntity>> castClosureVote({
    required String projectId,
    required bool voteForSuccess,
  });

  Future<Either<Failure, ActiveClosureVoteEntity?>> getActiveClosureVote(
    String projectId,
  );
}
