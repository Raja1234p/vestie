import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/paginated_result.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

import '../entities/created_project_entity.dart';

abstract class ProjectsRepository {
  Future<Either<Failure, PaginatedResult<Project>>> listProjects({
    required String scope,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<Either<Failure, PaginatedResult<Project>>> listCompletedProjects({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<Either<Failure, CreatedProjectEntity>> createProject({
    required CreateProjectForm form,
  });

  /// `POST /projects/{id}/launch` after [createProject] (Draft → Active).
  Future<Either<Failure, void>> launchProject(String projectId);

  /// Creates then launches in one flow (wizard review submit).
  Future<Either<Failure, CreatedProjectEntity>> createAndLaunchProject({
    required CreateProjectForm form,
  });

  /// `PUT /projects/{id}` — leader edit from project detail.
  Future<Either<Failure, void>> updateProject({
    required String projectId,
    required CreateProjectForm form,
  });
}
