import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/borrow_repository.dart';

class RejectBorrowRequestUseCase {
  final BorrowRepository _repository;

  RejectBorrowRequestUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _repository.rejectBorrowRequest(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
    );
  }
}
