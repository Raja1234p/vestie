import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import '../repositories/projects_repository.dart';

/// Leader edit — `PUT /projects/{id}` with the same body as create.
class UpdateProjectUseCase {
  final ProjectsRepository _repository;

  UpdateProjectUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required CreateProjectForm form,
  }) {
    return _repository.updateProject(projectId: projectId, form: form);
  }
}
