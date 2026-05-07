import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../domain/repositories/project_repository.dart';

class GetProjectDetailUseCase {
  final ProjectRepository repository;

  GetProjectDetailUseCase(this.repository);

  Future<Either<Failure, ProjectDetailEntity>> call(String projectId) async {
    return await repository.getProjectDetail(projectId);
  }
}
