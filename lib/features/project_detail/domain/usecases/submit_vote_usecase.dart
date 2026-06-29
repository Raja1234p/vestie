import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/closure_vote_entities.dart';
import '../repositories/closure_voting_repository.dart';

class SubmitVoteParams {
  final String projectId;
  final bool isPositive;

  const SubmitVoteParams({required this.projectId, required this.isPositive});
}

class SubmitVoteUseCase {
  final ClosureVotingRepository repository;

  SubmitVoteUseCase({required this.repository});

  Future<Either<Failure, CastClosureVoteResultEntity>> call(
    SubmitVoteParams params,
  ) {
    return repository.castClosureVote(
      projectId: params.projectId,
      voteForSuccess: params.isPositive,
    );
  }
}
