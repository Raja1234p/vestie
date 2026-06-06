import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class VotingRepository {
  Future<Either<Failure, void>> submitVote(String projectId, bool isPositive);
  Future<Either<Failure, void>> requestVoteExtension(
    String projectId,
    int extraDays,
    String reason,
  );
  Future<Either<Failure, void>> finalizeVote(String projectId);
  Future<Either<Failure, void>> cancelProject(String projectId, String reason);
}
