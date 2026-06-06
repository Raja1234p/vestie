import 'package:dartz/dartz.dart';

import '../../../../../core/error/failure_mapper.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/vff_connection_entity.dart';
import '../../domain/entities/vff_inbox_entity.dart';
import '../../domain/entities/vff_profile_entity.dart';
import '../../domain/repositories/vff_repository.dart';
import '../datasources/vff_remote_data_source.dart';

class VffRepositoryImpl implements VffRepository {
  final VffRemoteDataSource remoteDataSource;

  VffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<VffConnectionEntity>>> listMyVffs() async {
    return _mapList(
      () => remoteDataSource.listMyVffs(),
      (models) => models.map((m) => m.toEntity()).toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, VffConnectedProfileEntity>> getConnectedProfile(
    String userId,
  ) async {
    return _map(
      () => remoteDataSource.getConnectedProfile(userId),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffPublicProfileEntity>> getPublicProfile(
    String userId,
  ) async {
    return _map(
      () => remoteDataSource.getPublicProfile(userId),
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
  Future<Either<Failure, VffReceivedInboxEntity>> getReceivedInbox() async {
    return _map(
      () => remoteDataSource.getReceivedInbox(),
      (model) => model.toEntity(),
    );
  }

  @override
  Future<Either<Failure, VffSentInboxEntity>> getSentInbox() async {
    return _map(
      () => remoteDataSource.getSentInbox(),
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
