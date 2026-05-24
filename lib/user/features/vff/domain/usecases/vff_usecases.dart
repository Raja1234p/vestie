import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';

import '../entities/vff_connection_entity.dart';
import '../entities/vff_inbox_entity.dart';
import '../entities/vff_profile_entity.dart';
import '../repositories/vff_repository.dart';

class ListMyVffsUseCase {
  final VffRepository _repository;

  ListMyVffsUseCase(this._repository);

  Future<Either<Failure, List<VffConnectionEntity>>> call() {
    return _repository.listMyVffs();
  }
}

class GetConnectedVffProfileUseCase {
  final VffRepository _repository;

  GetConnectedVffProfileUseCase(this._repository);

  Future<Either<Failure, VffConnectedProfileEntity>> call(String userId) {
    return _repository.getConnectedProfile(userId);
  }
}

class GetPublicVffProfileUseCase {
  final VffRepository _repository;

  GetPublicVffProfileUseCase(this._repository);

  Future<Either<Failure, VffPublicProfileEntity>> call(String userId) {
    return _repository.getPublicProfile(userId);
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

  Future<Either<Failure, VffReceivedInboxEntity>> call() {
    return _repository.getReceivedInbox();
  }
}

class GetVffSentInboxUseCase {
  final VffRepository _repository;

  GetVffSentInboxUseCase(this._repository);

  Future<Either<Failure, VffSentInboxEntity>> call() {
    return _repository.getSentInbox();
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
