import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/borrow_repay_entities.dart';
import '../repositories/borrow_repository.dart';

class SubmitBorrowRepaymentUseCase {
  final BorrowRepository _repository;

  SubmitBorrowRepaymentUseCase(this._repository);

  Future<Either<Failure, BorrowRepaymentResultEntity>> call({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
    required String idempotencyKey,
  }) {
    return _repository.submitBorrowRepayment(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
      paymentSourceType: paymentSourceType,
      paymentMethodId: paymentMethodId,
      idempotencyKey: idempotencyKey,
    );
  }
}
