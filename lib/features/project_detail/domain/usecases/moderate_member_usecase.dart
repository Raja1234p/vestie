import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/project_actions_repository.dart';

enum ModerationAction { approve, reject, remove, promote, demote }

class ModerateMemberParams {
  final String projectId;
  final String userId;
  final ModerationAction action;

  const ModerateMemberParams({
    required this.projectId,
    required this.userId,
    required this.action,
  });
}

class ModerateMemberUseCase {
  final ProjectActionsRepository repository;

  ModerateMemberUseCase({required this.repository});

  Future<Either<Failure, void>> call(ModerateMemberParams params) async {
    switch (params.action) {
      case ModerationAction.approve:
        return repository.approveJoinRequest(params.projectId, params.userId);
      case ModerationAction.reject:
        return repository.rejectJoinRequest(params.projectId, params.userId);
      case ModerationAction.remove:
        return repository.removeMember(params.projectId, params.userId);
      case ModerationAction.promote:
        return repository.promoteToCoLeader(params.projectId, params.userId);
      case ModerationAction.demote:
        return repository.demoteCoLeader(params.projectId, params.userId);
    }
  }
}
