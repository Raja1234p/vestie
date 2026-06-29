import 'package:dartz/dartz.dart';

import 'package:vestie/core/domain/entities/paginated_result.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/models/pagination_dto.dart';

import '../entities/vff_connection_entity.dart';
import '../entities/vff_inbox_entity.dart';
import '../entities/vff_profile_entity.dart';
import '../repositories/vff_repository.dart';

class ListMyVffsUseCase {
  final VffRepository _repository;

  ListMyVffsUseCase(this._repository);

  Future<Either<Failure, PaginatedResult<VffConnectionEntity>>> call({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) {
    return _repository.listMyVffs(page: page, pageSize: pageSize);
  }
}

class GetConnectedVffProfileUseCase {
  final VffRepository _repository;

  GetConnectedVffProfileUseCase(this._repository);

  Future<Either<Failure, VffConnectedProfileEntity>> call(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  }) {
    return _repository.getConnectedProfile(
      userId,
      projectsPage: projectsPage,
      projectsPageSize: projectsPageSize,
    );
  }
}

class GetPublicVffProfileUseCase {
  final VffRepository _repository;

  GetPublicVffProfileUseCase(this._repository);

  Future<Either<Failure, VffPublicProfileEntity>> call(
    String userId, {
    int projectsPage = PaginationQuery.defaultPage,
    int? projectsPageSize,
  }) {
    return _repository.getPublicProfile(
      userId,
      projectsPage: projectsPage,
      projectsPageSize: projectsPageSize,
    );
  }
}

class RemoveVffConnectionUseCase {
  final VffRepository _repository;

  RemoveVffConnectionUseCase(this._repository);

  Future<Either<Failure, VffRemoveConnectionResultEntity>> call(String userId) {
    return _repository.removeConnection(userId);
  }
}

class GetVffReceivedInboxUseCase {
  final VffRepository _repository;

  GetVffReceivedInboxUseCase(this._repository);

  Future<Either<Failure, VffReceivedInboxEntity>> call({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
  }) {
    return _repository.getReceivedInbox(
      vffRequestsPage: vffRequestsPage,
      vffRequestsPageSize: vffRequestsPageSize,
      projectInvitesPage: projectInvitesPage,
      projectInvitesPageSize: projectInvitesPageSize,
    );
  }
}

class GetVffSentInboxUseCase {
  final VffRepository _repository;

  GetVffSentInboxUseCase(this._repository);

  Future<Either<Failure, VffSentInboxEntity>> call({
    int vffRequestsPage = PaginationQuery.defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = PaginationQuery.defaultPage,
    int? projectInvitesPageSize,
    int joinRequestsPage = PaginationQuery.defaultPage,
    int? joinRequestsPageSize,
  }) {
    return _repository.getSentInbox(
      vffRequestsPage: vffRequestsPage,
      vffRequestsPageSize: vffRequestsPageSize,
      projectInvitesPage: projectInvitesPage,
      projectInvitesPageSize: projectInvitesPageSize,
      joinRequestsPage: joinRequestsPage,
      joinRequestsPageSize: joinRequestsPageSize,
    );
  }
}

class SendVffRequestUseCase {
  final VffRepository _repository;

  SendVffRequestUseCase(this._repository);

  Future<Either<Failure, VffSendRequestResultEntity>> call({
    required String projectId,
    required String userId,
  }) {
    return _repository.sendVffRequest(projectId: projectId, userId: userId);
  }
}

class AcceptVffRequestUseCase {
  final VffRepository _repository;

  AcceptVffRequestUseCase(this._repository);

  Future<Either<Failure, VffInboxRequestEntity>> call(String requestId) {
    return _repository.acceptVffRequest(requestId);
  }
}

class DeclineVffRequestUseCase {
  final VffRepository _repository;

  DeclineVffRequestUseCase(this._repository);

  Future<Either<Failure, VffInboxRequestEntity>> call(String requestId) {
    return _repository.declineVffRequest(requestId);
  }
}

class InviteVffsToProjectUseCase {
  final VffRepository _repository;

  InviteVffsToProjectUseCase(this._repository);

  Future<Either<Failure, List<VffInviteResultEntity>>> call({
    required String projectId,
    required List<String> userIds,
  }) {
    return _repository.inviteVffsToProject(
      projectId: projectId,
      userIds: userIds,
    );
  }
}

class AcceptVffProjectInviteUseCase {
  final VffRepository _repository;

  AcceptVffProjectInviteUseCase(this._repository);

  Future<Either<Failure, VffInviteResultEntity>> call({
    required String projectId,
    required String inviteId,
  }) {
    return _repository.acceptProjectInvite(
      projectId: projectId,
      inviteId: inviteId,
    );
  }
}

class DeclineVffProjectInviteUseCase {
  final VffRepository _repository;

  DeclineVffProjectInviteUseCase(this._repository);

  Future<Either<Failure, VffInviteResultEntity>> call({
    required String projectId,
    required String inviteId,
  }) {
    return _repository.declineProjectInvite(
      projectId: projectId,
      inviteId: inviteId,
    );
  }
}

class JoinFromVffProfileUseCase {
  final VffRepository _repository;

  JoinFromVffProfileUseCase(this._repository);

  Future<Either<Failure, VffJoinFromVffResultEntity>> call({
    required String projectId,
  }) {
    return _repository.joinFromVffProfile(projectId: projectId);
  }
}
