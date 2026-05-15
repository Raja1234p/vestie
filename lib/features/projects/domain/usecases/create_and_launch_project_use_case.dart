import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import '../entities/created_project_entity.dart';
import '../repositories/projects_repository.dart';

/// Week 3/4 wizard submit: `POST /projects` then `POST /projects/{id}/launch`.
class CreateAndLaunchProjectUseCase {
  final ProjectsRepository _repository;

  CreateAndLaunchProjectUseCase(this._repository);

  Future<Either<Failure, CreatedProjectEntity>> call({
    required CreateProjectForm form,
  }) {
    return _repository.createAndLaunchProject(form: form);
  }
}
