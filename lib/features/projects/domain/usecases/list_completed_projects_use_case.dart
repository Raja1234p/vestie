import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/paginated_result.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import '../repositories/projects_repository.dart';

class ListCompletedProjectsUseCase {
  ListCompletedProjectsUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<Either<Failure, PaginatedResult<Project>>> call({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) {
    return _repository.listCompletedProjects(page: page, pageSize: pageSize);
  }
}
