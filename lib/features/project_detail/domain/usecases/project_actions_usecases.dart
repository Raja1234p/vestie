import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cancel_project_entities.dart';
import '../entities/closure_vote_entities.dart';
import '../repositories/project_actions_repository.dart';
import 'submit_vote_usecase.dart';

class ResolveGoalUseCase {
  final ProjectActionsRepository repository;
  ResolveGoalUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId}) async {
    return repository.resolveGoal(projectId: projectId);
  }
}

class ExtendDeadlineUseCase {
  final ProjectActionsRepository repository;
  ExtendDeadlineUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required int extraDays,
  }) async {
    return repository.extendDeadline(
      projectId: projectId,
      extraDays: extraDays,
    );
  }
}

class CompleteProjectUseCase {
  final ProjectActionsRepository repository;
  CompleteProjectUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId}) async {
    return repository.completeProject(projectId: projectId);
  }
}

class AssignCoLeaderUseCase {
  final ProjectActionsRepository repository;
  AssignCoLeaderUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String userId,
  }) async {
    return repository.promoteToCoLeader(projectId, userId);
  }
}

class RemoveCoLeaderUseCase {
  final ProjectActionsRepository repository;
  RemoveCoLeaderUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String userId,
  }) async {
    return repository.demoteCoLeader(projectId, userId);
  }
}

/// Assign (`POST`) or remove (`DELETE`) co-leader on the same member co-leader endpoint.
class UpdateCoLeaderRoleUseCase {
  final ProjectActionsRepository repository;
  UpdateCoLeaderRoleUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String userId,
    required bool assign,
  }) {
    return assign
        ? repository.promoteToCoLeader(projectId, userId)
        : repository.demoteCoLeader(projectId, userId);
  }
}

class RemoveMemberUseCase {
  final ProjectActionsRepository repository;
  RemoveMemberUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String userId,
  }) async {
    return repository.removeMember(projectId, userId);
  }
}

class MarkDefaultedUseCase {
  final ProjectActionsRepository repository;
  MarkDefaultedUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String userId,
  }) async {
    return repository.markDefaulted(projectId: projectId, userId: userId);
  }
}

class RemoveForNonRepaymentUseCase {
  final ProjectActionsRepository repository;
  RemoveForNonRepaymentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String userId,
  }) async {
    return repository.removeForNonRepayment(
      projectId: projectId,
      userId: userId,
    );
  }
}

class CastClosureVoteUseCase {
  final SubmitVoteUseCase _submitVoteUseCase;
  CastClosureVoteUseCase(this._submitVoteUseCase);

  Future<Either<Failure, CastClosureVoteResultEntity>> call({
    required String projectId,
    required bool voteForSuccess,
  }) {
    return _submitVoteUseCase(
      SubmitVoteParams(projectId: projectId, isPositive: voteForSuccess),
    );
  }
}

class ExtendClosureVotingUseCase {
  final ProjectActionsRepository repository;
  ExtendClosureVotingUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required int extraDays,
  }) async {
    return repository.extendClosureVoting(
      projectId: projectId,
      extraDays: extraDays,
    );
  }
}

class CancelProjectUseCase {
  final ProjectActionsRepository repository;
  CancelProjectUseCase(this.repository);

  Future<Either<Failure, CancelProjectResultEntity>> call({
    required String projectId,
  }) {
    return repository.cancelProject(projectId: projectId);
  }
}

class LeaveProjectUseCase {
  final ProjectActionsRepository repository;
  LeaveProjectUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId}) async {
    return repository.leaveProject(projectId: projectId);
  }
}

class ApproveMembershipUseCase {
  final ProjectActionsRepository repository;
  ApproveMembershipUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String membershipId,
  }) async {
    return repository.approveJoinRequest(projectId, membershipId);
  }
}

class RejectMembershipUseCase {
  final ProjectActionsRepository repository;
  RejectMembershipUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String projectId,
    required String membershipId,
  }) async {
    return repository.rejectJoinRequest(projectId, membershipId);
  }
}

class CreateInviteUseCase {
  final ProjectActionsRepository repository;
  CreateInviteUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String projectId,
    required bool requiresApproval,
    required int expiresInDays,
    required int maxUses,
  }) async {
    return repository.createInvite(
      projectId: projectId,
      requiresApproval: requiresApproval,
      expiresInDays: expiresInDays,
      maxUses: maxUses,
    );
  }
}

