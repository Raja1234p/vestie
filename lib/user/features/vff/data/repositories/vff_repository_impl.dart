import 'package:dartz/dartz.dart';

import '../../../../../core/domain/entities/paginated_result.dart';
import '../../../../../core/error/failure_mapper.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/models/pagination_dto.dart';
import '../../domain/entities/vff_connection_entity.dart';
import '../../domain/entities/vff_inbox_entity.dart';
import '../../domain/entities/vff_profile_entity.dart';
import '../../domain/repositories/vff_repository.dart';
import '../datasources/vff_remote_data_source.dart';

class VffRepositoryImpl implements VffRepository {
  final VffRemoteDataSource remoteDataSource;

  VffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResult<VffConnectionEntity>>> listMyVffs({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    return _mapPage(
      () => remoteDataSource.listMyVffs(page: page, pageSize: pageSize),
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, VffConnectedProfileEntity>> getConnectedProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  }) async {
    return _map(
      () => remoteDataSource.getConnectedProfile(
        userId,
        projectsPage: projectsPage,
        projectsPageSize: projectsPageSize,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffPublicProfileEntity>> getPublicProfile(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  }) async {
    return _map(
      () => remoteDataSource.getPublicProfile(
        userId,
        projectsPage: projectsPage,
        projectsPageSize: projectsPageSize,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffRemoveConnectionResultEntity>> removeConnection(
    String userId,
  ) async {
    return _map(
      () => remoteDataSource.removeConnection(userId),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffReceivedInboxEntity>> getReceivedInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
  }) async {
    return _map(
      () => remoteDataSource.getReceivedInbox(
        vffRequestsPage: vffRequestsPage,
        vffRequestsPageSize: vffRequestsPageSize,
        projectInvitesPage: projectInvitesPage,
        projectInvitesPageSize: projectInvitesPageSize,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffSentInboxEntity>> getSentInbox({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
    int joinRequestsPage = PaginationQuery.defaultPage,
    int? joinRequestsPageSize,
  }) async {
    return _map(
      () => remoteDataSource.getSentInbox(
        vffRequestsPage: vffRequestsPage,
        vffRequestsPageSize: vffRequestsPageSize,
        projectInvitesPage: projectInvitesPage,
        projectInvitesPageSize: projectInvitesPageSize,
        joinRequestsPage: joinRequestsPage,
        joinRequestsPageSize: joinRequestsPageSize,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffSendRequestResultEntity>> sendVffRequest({
    required String projectId,
    required String userId,
  }) async {
    return _map(
      () =>
          remoteDataSource.sendVffRequest(projectId: projectId, userId: userId),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffInboxRequestEntity>> acceptVffRequest(
    String requestId,
  ) async {
    return _map(
      () => remoteDataSource.acceptVffRequest(requestId),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffInboxRequestEntity>> declineVffRequest(
    String requestId,
  ) async {
    return _map(
      () => remoteDataSource.declineVffRequest(requestId),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, List<VffInviteResultEntity>>> inviteVffsToProject({
    required String projectId,
    required List<String> userIds,
  }) async {
    return _mapList(
      () => remoteDataSource.inviteVffsToProject(
        projectId: projectId,
        userIds: userIds,
      ),
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, VffInviteResultEntity>> acceptProjectInvite({
    required String projectId,
    required String inviteId,
  }) async {
    return _map(
      () => remoteDataSource.acceptProjectInvite(
        projectId: projectId,
        inviteId: inviteId,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffInviteResultEntity>> declineProjectInvite({
    required String projectId,
    required String inviteId,
  }) async {
    return _map(
      () => remoteDataSource.declineProjectInvite(
        projectId: projectId,
        inviteId: inviteId,
      ),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffJoinFromVffResultEntity>> joinFromVffProfile({
    required String projectId,
  }) async {
    return _map(
      () => remoteDataSource.joinFromVffProfile(projectId: projectId),
      (model) => model.toEntity(),
    );
  }

  Future<Either<Failure, T>> _map<T, M>(
    Future<M> Function() load,
    T Function(M model) map,
  ) async {
    try {
      final model = await load();
      return Right(map(model));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  Future<Either<Failure, PaginatedResult<T>>> _mapPage<T, M>(
    Future<PaginatedListModel<M>> Function() load,
    List<T> Function(List<M> models) mapItems,
  ) async {
    try {
      final pageModel = await load();
      return Right(
        PaginatedResult.fromPaginatedList(
          PaginatedListModel(
            items: mapItems(pageModel.items),
            pagination: pageModel.pagination,
          ),
        ),
      );
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  Future<Either<Failure, T>> _mapList<T, M>(
    Future<List<M>> Function() load,
    T Function(List<M> models) map,
  ) async {
    try {
      final models = await load();
      return Right(map(models));
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
