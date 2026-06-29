import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/closure_vote_entities.dart';
import '../repositories/closure_voting_repository.dart';

class OpenClosureVotingUseCase {
  final ClosureVotingRepository repository;
  OpenClosureVotingUseCase(this.repository);

  Future<Either<Failure, OpenClosureVoteEntity>> call({
    required String projectId,
    required int votingWindowDays,
    ClosureVoteType voteType = ClosureVoteType.successVote,
  }) {
    return repository.openClosureVoting(
      projectId: projectId,
      votingWindowDays: votingWindowDays,
      voteType: voteType,
    );
  }
}

class OpenStopContributionsVotingUseCase {
  final ClosureVotingRepository repository;
  OpenStopContributionsVotingUseCase(this.repository);

  Future<Either<Failure, OpenClosureVoteEntity>> call({
    required String projectId,
    required int votingWindowDays,
  }) {
    return repository.openClosureVoting(
      projectId: projectId,
      votingWindowDays: votingWindowDays,
      voteType: ClosureVoteType.stopContributionsVote,
    );
  }
}

class FinalizeClosureVotingUseCase {
  final ClosureVotingRepository repository;
  FinalizeClosureVotingUseCase(this.repository);

  Future<Either<Failure, FinalizeClosureVoteResultEntity>> call({
    required String projectId,
  }) {
    return repository.finalizeClosureVoting(projectId);
  }
}
