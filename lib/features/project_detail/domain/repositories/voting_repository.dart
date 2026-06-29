import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Legacy closure-voting helpers not in Week 10 (`extend`, cancel via voting DS).
abstract class VotingRepository {
  Future<Either<Failure, void>> requestVoteExtension(
    String projectId,
    int extraDays,
    String reason,
  );

  Future<Either<Failure, void>> cancelProject(String projectId, String reason);
}
