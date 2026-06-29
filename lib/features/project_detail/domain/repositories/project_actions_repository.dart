import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cancel_project_entities.dart';
import '../entities/member_activity_entity.dart';
import '../entities/pending_join_request_entity.dart';

abstract class ProjectActionsRepository {
  Future<Either<Failure, List<PendingJoinRequestEntity>>>
  listPendingJoinRequests(String projectId);

  Future<Either<Failure, MemberActivityEntity>> getMemberActivity({
    required String projectId,
    required String userId,
    required String projectName,
  });

  Future<Either<Failure, void>> approveJoinRequest(
    String projectId,
    String membershipId,
  );
  Future<Either<Failure, void>> rejectJoinRequest(
    String projectId,
    String membershipId,
  );
  Future<Either<Failure, void>> removeMember(String projectId, String userId);
  Future<Either<Failure, void>> promoteToCoLeader(
    String projectId,
    String userId,
  );
  Future<Either<Failure, void>> demoteCoLeader(String projectId, String userId);

  Future<Either<Failure, CancelProjectResultEntity>> cancelProject({
    required String projectId,
  });
  Future<Either<Failure, void>> leaveProject({required String projectId});
  Future<Either<Failure, String>> createInvite({
    required String projectId,
    required bool requiresApproval,
    required int expiresInDays,
    required int maxUses,
  });
  Future<Either<Failure, void>> markDefaulted({
    required String projectId,
    required String userId,
  });
  Future<Either<Failure, void>> removeForNonRepayment({
    required String projectId,
    required String userId,
  });
  Future<Either<Failure, void>> extendClosureVoting({
    required String projectId,
    required int extraDays,
  });
  Future<Either<Failure, void>> resolveGoal({required String projectId});
  Future<Either<Failure, void>> extendDeadline({
    required String projectId,
    required int extraDays,
  });
  Future<Either<Failure, void>> completeProject({required String projectId});
}
