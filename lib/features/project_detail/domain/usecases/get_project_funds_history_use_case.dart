import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../entities/project_funds_history_entity.dart';
import '../repositories/project_funds_history_repository.dart';

class GetProjectFundsHistoryUseCase {
  final ProjectFundsHistoryRepository repository;

  GetProjectFundsHistoryUseCase(this.repository);

  Future<Either<Failure, ProjectFundsHistoryEntity>> call(
    String projectId, {
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) {
    return repository.getFundsHistory(
      projectId: projectId,
      page: page,
      pageSize: pageSize,
    );
  }
}
