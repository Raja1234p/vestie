import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/paginated_result.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../entities/pending_join_request_entity.dart';
import '../repositories/project_actions_repository.dart';

class ListPendingJoinRequestsUseCase {
  final ProjectActionsRepository _repository;

  ListPendingJoinRequestsUseCase(this._repository);

  Future<Either<Failure, PaginatedResult<PendingJoinRequestEntity>>> call(
    String projectId, {
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) {
    return _repository.listPendingJoinRequests(
      projectId,
      page: page,
      pageSize: pageSize,
    );
  }
}
