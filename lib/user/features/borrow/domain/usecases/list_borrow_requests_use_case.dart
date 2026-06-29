import 'package:dartz/dartz.dart';

import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import '../repositories/borrow_repository.dart';

class ListBorrowRequestsUseCase {
  final BorrowRepository _repository;

  ListBorrowRequestsUseCase(this._repository);

  Future<Either<Failure, PaginatedResult<BorrowRequestEntity>>> call({
    required String projectId,
    String? status,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) {
    return _repository.listBorrowRequests(
      projectId: projectId,
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }
}
