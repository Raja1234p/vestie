import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import '../repositories/borrow_repository.dart';

class ListBorrowRequestsUseCase {
  final BorrowRepository _repository;

  ListBorrowRequestsUseCase(this._repository);

  Future<Either<Failure, List<BorrowRequestEntity>>> call({
    required String projectId,
    String? status,
  }) {
    return _repository.listBorrowRequests(projectId: projectId, status: status);
  }
}
