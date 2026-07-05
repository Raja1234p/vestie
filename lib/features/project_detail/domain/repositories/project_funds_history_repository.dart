import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../entities/project_funds_history_entity.dart';

abstract class ProjectFundsHistoryRepository {
  Future<Either<Failure, ProjectFundsHistoryEntity>> getFundsHistory({
    required String projectId,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });
}
