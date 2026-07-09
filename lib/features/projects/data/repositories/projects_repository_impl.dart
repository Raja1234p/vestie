import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/domain/entities/paginated_result.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import '../../domain/entities/created_project_entity.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';
import '../models/create_project_request_model.dart';
import '../models/project_summary_model.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource remoteDataSource;

  ProjectsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaginatedResult<Project>>> listProjects({
    required String scope,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    try {
      final pageModel = await remoteDataSource.listProjects(
        scope: scope,
        page: page,
        pageSize: pageSize,
      );
      return Right(_mapProjectPage(pageModel, scope: scope));
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
  Future<Either<Failure, PaginatedResult<Project>>> listCompletedProjects({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    try {
      final pageModel = await remoteDataSource.listCompletedProjects(
        page: page,
        pageSize: pageSize,
      );
      return Right(_mapProjectPage(pageModel, scope: 'mine'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.title));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.title));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure(AppStrings.errorLoadCompletedProjects));
    }
  }

  PaginatedResult<Project> _mapProjectPage(
    PaginatedListModel<ProjectSummaryModel> pageModel, {
    required String scope,
  }) {
    return PaginatedResult.fromPaginatedList(
      PaginatedListModel(
        items: pageModel.items.map((m) => _mapSummary(m, scope: scope)).toList(
          growable: false,
        ),
        pagination: pageModel.pagination,
      ),
    );
  }

  Project _mapSummary(
    ProjectSummaryModel m, {
    required String scope,
  }) {
    final statusLabel = m.displayStatus.isNotEmpty ? m.displayStatus : m.state;
    return Project(
      id: m.id,
      name: m.name,
      category: _mapCategory(m.type),
      status: _mapStatus(statusLabel),
      relation: _mapRelation(scope: scope, viewerRole: m.viewerRole),
      goalAmount: m.targetAmount,
      currentAmount: m.raisedDisplayAmount,
      description: m.description,
      endsIn: m.endsAtUtc?.toIso8601String(),
      roiPercentage: m.roiPercentage,
      displayStatus: m.displayStatus.isNotEmpty ? m.displayStatus : null,
      projectInviteCode: m.projectInviteCode,
      isPublic: _isPublicVisibility(m.visibility),
      coverImageUrl: m.coverImageUrl,
      images: m.images,
      viewerRole: m.viewerMembershipRole,
      memberCount: m.eligibleMemberCount > 0 ? m.eligibleMemberCount : m.maxMembers,
      successVoteApproved: m.successVoteApproved,
      lastVoteType: m.lastVoteType,
      lastVoteOutcome: m.lastVoteOutcome,
      distributionStatus: m.distributionStatus,
    );
  }

  @override
  Future<Either<Failure, CreatedProjectEntity>> createProject({
    required CreateProjectForm form,
  }) async {
    try {
      final response = await remoteDataSource.createProject(
        request: CreateProjectRequestModel.fromForm(form),
        imagePaths: form.projectImagePaths,
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

  @override
  Future<Either<Failure, void>> launchProject(String projectId) async {
    if (projectId.isEmpty) {
      return const Left(ServerFailure(AppStrings.errorGeneric));
    }
    try {
      await remoteDataSource.launchProject(projectId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.title));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.title));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure(AppStrings.errorLaunchProject));
    }
  }

  @override
  Future<Either<Failure, void>> updateProject({
    required String projectId,
    required CreateProjectForm form,
  }) async {
    if (projectId.isEmpty) {
      return const Left(ServerFailure(AppStrings.errorGeneric));
    }
    try {
      await remoteDataSource.updateProject(
        projectId: projectId,
        request: CreateProjectRequestModel.fromForm(form),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.title));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.title));
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return const Left(ServerFailure(AppStrings.errorUpdateProject));
    }
  }

  @override
  Future<Either<Failure, CreatedProjectEntity>> createAndLaunchProject({
    required CreateProjectForm form,
  }) async {
    final created = await createProject(form: form);
    return created.fold(Left.new, (entity) async {
      if (entity.id.isEmpty) {
        return const Left(ServerFailure(AppStrings.errorGeneric));
      }
      final launched = await launchProject(entity.id);
      return launched.fold((failure) => Left(failure), (_) => Right(entity));
    });
  }

  bool _isPublicVisibility(String visibility) {
    final v = visibility.toLowerCase().trim();
    if (v == 'private' || v == '2') return false;
    return true;
  }

  ProjectCategory _mapCategory(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('invest')) return ProjectCategory.investment;
    if (normalized.contains('emerg')) return ProjectCategory.emergency;
    return ProjectCategory.vacations;
  }

  ProjectStatus _mapStatus(String state) {
    final normalized = state.toLowerCase();
    if (normalized.contains('draft') || normalized.contains('active')) {
      return ProjectStatus.ongoing;
    }
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

    final parsed = ViewerMembershipRole.parse(viewerRole);
    if (parsed.isGroupLeader || parsed.isCoLeader) {
      return ProjectRelation.owned;
    }
    if (parsed.isMember) return ProjectRelation.joined;

    return ProjectRelation.owned;
  }
}
