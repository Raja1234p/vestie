import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/borrow_repository.dart';

class CreateBorrowRequestUseCase {
  final BorrowRepository _repository;

  CreateBorrowRequestUseCase(this._repository);

  Future<Either<Failure, BorrowRequestResult>> call({
    required String projectId,
    required double amount,
    required String reason,
    required String idempotencyKey,
  }) {
    return _repository.createBorrowRequest(
      projectId: projectId,
      amount: amount,
      reason: reason,
      idempotencyKey: idempotencyKey,
    );
  }
}
