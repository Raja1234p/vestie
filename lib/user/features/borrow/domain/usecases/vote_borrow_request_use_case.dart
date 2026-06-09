import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/borrow_repository.dart';

class VoteBorrowRequestUseCase {
  final BorrowRepository _repository;

  VoteBorrowRequestUseCase(this._repository);

  Future<Either<Failure, BorrowVoteResult>> call({
    required String projectId,
    required String borrowRequestId,
    required String vote,
  }) {
    return _repository.voteBorrowRequest(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
      vote: vote,
    );
  }
}
