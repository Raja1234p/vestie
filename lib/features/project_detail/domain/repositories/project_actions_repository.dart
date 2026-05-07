import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ProjectActionsRepository {
  Future<Either<Failure, void>> approveJoinRequest(String projectId, String userId);
  Future<Either<Failure, void>> rejectJoinRequest(String projectId, String userId);
  Future<Either<Failure, void>> removeMember(String projectId, String userId);
  Future<Either<Failure, void>> promoteToCoLeader(String projectId, String userId);
  Future<Either<Failure, void>> demoteCoLeader(String projectId, String userId);
}
