import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/project_actions_repository.dart';

class ResolveGoalUseCase {
  final ProjectActionsRepository repository;
  ResolveGoalUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class ExtendDeadlineUseCase {
  final ProjectActionsRepository repository;
  ExtendDeadlineUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class CompleteProjectUseCase {
  final ProjectActionsRepository repository;
  CompleteProjectUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class AssignCoLeaderUseCase {
  final ProjectActionsRepository repository;
  AssignCoLeaderUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId, required String userId}) async {
    return const Right(null);
  }
}

class RemoveCoLeaderUseCase {
  final ProjectActionsRepository repository;
  RemoveCoLeaderUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId, required String userId}) async {
    return const Right(null);
  }
}

class RemoveMemberUseCase {
  final ProjectActionsRepository repository;
  RemoveMemberUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId, required String userId}) async {
    return const Right(null);
  }
}

class MarkDefaultedUseCase {
  final ProjectActionsRepository repository;
  MarkDefaultedUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId, required String userId}) async {
    return const Right(null);
  }
}

class RemoveForNonRepaymentUseCase {
  final ProjectActionsRepository repository;
  RemoveForNonRepaymentUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId, required String userId}) async {
    return const Right(null);
  }
}

class CastClosureVoteUseCase {
  final ProjectActionsRepository repository;
  CastClosureVoteUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class ExtendClosureVotingUseCase {
  final ProjectActionsRepository repository;
  ExtendClosureVotingUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class FinalizeClosureVotingUseCase {
  final ProjectActionsRepository repository;
  FinalizeClosureVotingUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class CancelProjectUseCase {
  final ProjectActionsRepository repository;
  CancelProjectUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId}) async {
    return const Right(null);
  }
}

class ApproveMembershipUseCase {
  final ProjectActionsRepository repository;
  ApproveMembershipUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
  }
}

class RejectMembershipUseCase {
  final ProjectActionsRepository repository;
  RejectMembershipUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return const Right(null);
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
    return const Right('dummy_invite_code');
  }
}

class OpenClosureVotingUseCase {
  final ProjectActionsRepository repository;
  OpenClosureVotingUseCase(this.repository);

  Future<Either<Failure, void>> call({required String projectId}) async {
    return const Right(null);
  }
}
