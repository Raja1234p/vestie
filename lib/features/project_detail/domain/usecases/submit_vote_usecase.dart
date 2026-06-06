import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/voting_repository.dart';

class SubmitVoteParams {
  final String projectId;
  final bool isPositive;

  const SubmitVoteParams({required this.projectId, required this.isPositive});
}

class SubmitVoteUseCase {
  final VotingRepository repository;

  SubmitVoteUseCase({required this.repository});

  Future<Either<Failure, void>> call(SubmitVoteParams params) async {
    return repository.submitVote(params.projectId, params.isPositive);
  }
}
