import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import '../../domain/entities/created_project_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';
import '../models/create_project_request_model.dart';

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
        category: _mapCategory(m.type),
        status: _mapStatus(m.state),
        relation: _mapRelation(scope: scope, viewerRole: m.viewerRole),
        goalAmount: m.targetAmount,
        currentAmount: 0.0,
        description: m.description,
        endsIn: m.endsAtUtc.toIso8601String(),
      )).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.title));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.title));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure('Failed to load projects'));
    }
  }

  @override
  Future<Either<Failure, CreatedProjectEntity>> createProject({required CreateProjectForm form}) async {
    try {
      final response = await remoteDataSource.createProject(
        request: CreateProjectRequestModel.fromForm(form),
      );
      return Right(response.entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.title));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.title));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  ProjectCategory _mapCategory(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('invest')) return ProjectCategory.investment;
    if (normalized.contains('emerg')) return ProjectCategory.emergency;
    return ProjectCategory.vacations;
  }

  ProjectStatus _mapStatus(String state) {
    final normalized = state.toLowerCase();
    if (normalized.contains('complete') || normalized.contains('cancel')) {
      return ProjectStatus.completed;
    }
    return ProjectStatus.ongoing;
  }

  ProjectRelation _mapRelation({
    required String scope,
    required String viewerRole,
  }) {
    if (scope.toLowerCase() != 'mine') {
      // Discover list cards still use Join CTA in current UX.
      return ProjectRelation.joined;
    }

    final role = viewerRole.toLowerCase();
    if (role.contains('leader')) return ProjectRelation.owned;
    if (role.contains('member')) return ProjectRelation.joined;

    // Backward-safe fallback when backend omits role in list payload.
    return ProjectRelation.owned;
  }
}
