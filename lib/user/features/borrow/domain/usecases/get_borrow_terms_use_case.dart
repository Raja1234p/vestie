import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/borrow_terms_entity.dart';
import '../repositories/borrow_repository.dart';

class GetBorrowTermsUseCase {
  final BorrowRepository _repository;

  GetBorrowTermsUseCase(this._repository);

  Future<Either<Failure, BorrowTermsEntity>> call({
    required String projectId,
    required double amount,
  }) {
    return _repository.getBorrowTerms(projectId: projectId, amount: amount);
  }
}
