import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/borrow_repository.dart';

class CreateBorrowRequestUseCase {
  final BorrowRepository _repository;

  CreateBorrowRequestUseCase(this._repository);

  Future<Either<Failure, BorrowRequestResult>> call({
    required String projectId,
    required double amount,
    required String reason,
  }) {
    return _repository.createBorrowRequest(
      projectId: projectId,
      amount: amount,
      reason: reason,
    );
  }
}

