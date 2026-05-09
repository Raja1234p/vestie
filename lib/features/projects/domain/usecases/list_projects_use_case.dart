import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import '../repositories/projects_repository.dart';

class ListProjectsUseCase {
  final ProjectsRepository _repository;

  ListProjectsUseCase(this._repository);

  Future<Either<Failure, List<Project>>> call({required String scope}) {
    return _repository.listProjects(scope: scope);
  }
}

