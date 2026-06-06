import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_summary_entity.dart';
import '../repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  Future<Either<Failure, List<ProjectSummaryEntity>>> call({
    required String scope,
  }) async {
    return await repository.getProjects(scope: scope);
  }
}
