import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/borrow_repository.dart';

class ApproveBorrowRequestUseCase {
  final BorrowRepository _repository;

  ApproveBorrowRequestUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String borrowRequestId,
  }) {
    return _repository.approveBorrowRequest(
      projectId: projectId,
      borrowRequestId: borrowRequestId,
    );
  }
}
