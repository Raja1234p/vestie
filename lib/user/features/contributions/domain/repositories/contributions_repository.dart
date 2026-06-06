import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../value_objects/contribution_flow_models.dart';

abstract class ContributionsRepository {
  Future<Either<Failure, ContributionConfig>> getConfig({
    required String projectId,
  });

  Future<Either<Failure, ContributionPreview>> preview({
    required ContributionInput input,
  });

  Future<Either<Failure, ContributionResult>> confirm({
    required ContributionInput input,
  });
}
