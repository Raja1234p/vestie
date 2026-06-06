import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

import '../entities/created_project_entity.dart';

abstract class ProjectsRepository {
  Future<Either<Failure, List<Project>>> listProjects({required String scope});

  Future<Either<Failure, CreatedProjectEntity>> createProject({
    required CreateProjectForm form,
  });

  /// `POST /projects/{id}/launch` after [createProject] (Draft → Active).
  Future<Either<Failure, void>> launchProject(String projectId);

  /// Creates then launches in one flow (wizard review submit).
  Future<Either<Failure, CreatedProjectEntity>> createAndLaunchProject({
    required CreateProjectForm form,
  });
}
