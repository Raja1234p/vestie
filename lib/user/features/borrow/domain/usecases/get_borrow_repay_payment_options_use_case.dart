import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/borrow_repay_entities.dart';
import '../repositories/borrow_repository.dart';

class GetBorrowRepayPaymentOptionsUseCase {
  final BorrowRepository _repository;

  GetBorrowRepayPaymentOptionsUseCase(this._repository);

  Future<Either<Failure, BorrowRepayPaymentOptionsEntity>> call({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _repository.getBorrowRepayPaymentOptions(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
    );
  }
}
