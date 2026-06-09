import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/borrow_repository.dart';

class CancelBorrowRequestUseCase {
  final BorrowRepository _repository;

  CancelBorrowRequestUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _repository.cancelBorrowRequest(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
    );
  }
}
