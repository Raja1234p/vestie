import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/borrow_repay_entities.dart';
import '../repositories/borrow_repository.dart';

class GetBorrowRepayPreviewUseCase {
  final BorrowRepository _repository;

  GetBorrowRepayPreviewUseCase(this._repository);

  Future<Either<Failure, BorrowRepayPreviewEntity>> call({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
  }) {
    return _repository.getBorrowRepayPreview(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
      paymentSourceType: paymentSourceType,
      paymentMethodId: paymentMethodId,
    );
  }
}
