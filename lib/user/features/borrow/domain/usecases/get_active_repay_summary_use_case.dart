import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/borrow_repay_entities.dart';
import '../repositories/borrow_repository.dart';

class GetActiveRepaySummaryUseCase {
  final BorrowRepository _repository;

  GetActiveRepaySummaryUseCase(this._repository);

  Future<Either<Failure, BorrowRepaySummaryEntity?>> call({
    required String projectId,
  }) {
    return _repository.getActiveRepaySummary(projectId: projectId);
  }
}
