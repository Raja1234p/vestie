import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/closure_vote_entities.dart';
import '../repositories/closure_voting_repository.dart';

class GetActiveClosureVoteUseCase {
  final ClosureVotingRepository repository;

  GetActiveClosureVoteUseCase(this.repository);

  Future<Either<Failure, ActiveClosureVoteEntity?>> call(String projectId) {
    return repository.getActiveClosureVote(projectId);
  }
}
