import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/borrow_repay_entities.dart';
import '../repositories/borrow_repository.dart';

class GetBorrowRepaySummaryUseCase {
  final BorrowRepository _repository;

  GetBorrowRepaySummaryUseCase(this._repository);

  Future<Either<Failure, BorrowRepaySummaryEntity>> call({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _repository.getBorrowRepaySummary(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
    );
  }
}
