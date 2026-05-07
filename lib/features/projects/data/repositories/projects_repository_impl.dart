import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/project.dart';
import '../../../create_project/domain/create_project_form.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource remoteDataSource;

  ProjectsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Project>>> listProjects({required String scope}) async {
    try {
      final models = await remoteDataSource.listProjects(scope: scope);
      return Right(models.map((m) => Project(
        id: m.id,
        name: m.name,
        category: ProjectCategory.vacations,
        status: m.state.toLowerCase() == 'ongoing' ? ProjectStatus.ongoing : ProjectStatus.completed,
        relation: ProjectRelation.owned,
        goalAmount: m.targetAmount,
        currentAmount: 0.0,
      )).toList());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createProject({required CreateProjectForm form}) async {
    return const Right('dummy_project_id');
  }
}
