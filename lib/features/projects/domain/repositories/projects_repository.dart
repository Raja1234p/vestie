import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';

abstract class ProjectsRepository {
  Future<Either<Failure, List<Project>>> listProjects({required String scope});

  Future<Either<Failure, String>> createProject({
    required CreateProjectForm form,
  });
}

