import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/paginated_result.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../../domain/entities/cancel_project_entities.dart';
import '../../domain/entities/member_activity_entity.dart';
import '../../domain/entities/pending_join_request_entity.dart';
import '../../domain/repositories/project_actions_repository.dart';
import '../datasources/project_actions_remote_data_source.dart';

class ProjectActionsRepositoryImpl implements ProjectActionsRepository {
  final ProjectActionsRemoteDataSource remoteDataSource;

  ProjectActionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResult<PendingJoinRequestEntity>>>
  listPendingJoinRequests(
    String projectId, {
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    try {
      final pageModel = await remoteDataSource.listPendingJoinRequests(
        projectId,
        page: page,
        pageSize: pageSize,
      );
      return Right(
        PaginatedResult.fromPaginatedList(
          PaginatedListModel(
            items: pageModel.items.map((m) => m.toEntity()).toList(),
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

  @override
  Future<Either<Failure, MemberActivityEntity>> getMemberActivity({
    required String projectId,
    required String userId,
    required String projectName,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    try {
      final model = await remoteDataSource.getMemberActivity(
        projectId: projectId,
        userId: userId,
        projectName: projectName,
        page: page,
        pageSize: pageSize,
      );
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> approveJoinRequest(
    String projectId,
    String membershipId,
  ) async {
    return _execute(
      () => remoteDataSource.approveJoinRequest(projectId, membershipId),
    );
  }

  @override
  Future<Either<Failure, void>> rejectJoinRequest(
    String projectId,
    String membershipId,
  ) async {
    return _execute(
      () => remoteDataSource.rejectJoinRequest(projectId, membershipId),
    );
  }

  @override
  Future<Either<Failure, void>> removeMember(
    String projectId,
    String userId,
  ) async {
    return _execute(() => remoteDataSource.removeMember(projectId, userId));
  }

  @override
  Future<Either<Failure, void>> promoteToCoLeader(
    String projectId,
    String userId,
  ) async {
    return _execute(
      () => remoteDataSource.promoteToCoLeader(projectId, userId),
    );
  }

  @override
  Future<Either<Failure, void>> demoteCoLeader(
    String projectId,
    String userId,
  ) async {
    return _execute(() => remoteDataSource.demoteCoLeader(projectId, userId));
  }

  @override
  Future<Either<Failure, CancelProjectResultEntity>> cancelProject({
    required String projectId,
  }) async {
    try {
      final model = await remoteDataSource.cancelProject(projectId: projectId);
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> leaveProject({
    required String projectId,
  }) async {
    return _execute(() => remoteDataSource.leaveProject(projectId: projectId));
  }

  @override
  Future<Either<Failure, String>> createInvite({
    required String projectId,
    required bool requiresApproval,
    required int expiresInDays,
    required int maxUses,
  }) async {
    try {
      final code = await remoteDataSource.createInvite(
        projectId: projectId,
        requiresApproval: requiresApproval,
        expiresInDays: expiresInDays,
        maxUses: maxUses,
      );
      return Right(code);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markDefaulted({
    required String projectId,
    required String userId,
  }) async {
    return _execute(
      () =>
          remoteDataSource.markDefaulted(projectId: projectId, userId: userId),
    );
  }

  @override
  Future<Either<Failure, void>> removeForNonRepayment({
    required String projectId,
    required String userId,
  }) async {
    return _execute(
      () => remoteDataSource.removeForNonRepayment(
        projectId: projectId,
        userId: userId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> extendClosureVoting({
    required String projectId,
    required int extraDays,
  }) async {
    return _execute(
      () => remoteDataSource.extendClosureVoting(
        projectId: projectId,
        extraDays: extraDays,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> resolveGoal({required String projectId}) async {
    return _execute(() => remoteDataSource.resolveGoal(projectId: projectId));
  }

  @override
  Future<Either<Failure, void>> extendDeadline({
    required String projectId,
    required int extraDays,
  }) async {
    return _execute(
      () => remoteDataSource.extendDeadline(
        projectId: projectId,
        extraDays: extraDays,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> completeProject({
    required String projectId,
  }) async {
    return _execute(
      () => remoteDataSource.completeProject(projectId: projectId),
    );
  }

  Future<Either<Failure, void>> _execute(Future<void> Function() action) async {
    try {
      await action();
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
