import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/contributions_repository.dart';
import '../value_objects/contribution_flow_models.dart';

class GetContributionConfigUseCase {
  final ContributionsRepository _repository;

  GetContributionConfigUseCase(this._repository);

  Future<Either<Failure, ContributionConfig>> call({
    required String projectId,
  }) {
    return _repository.getConfig(projectId: projectId);
  }
}

