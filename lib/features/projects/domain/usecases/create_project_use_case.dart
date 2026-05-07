import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../create_project/domain/create_project_form.dart';
import '../repositories/projects_repository.dart';

class CreateProjectUseCase {
  final ProjectsRepository _repository;

  CreateProjectUseCase(this._repository);

  Future<Either<Failure, String>> call({required CreateProjectForm form}) {
    return _repository.createProject(form: form);
  }
}

