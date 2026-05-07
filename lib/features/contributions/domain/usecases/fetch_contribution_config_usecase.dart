import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/contribution_config_entity.dart';
import '../repositories/contribution_repository.dart';

class FetchContributionConfigUseCase {
  final ContributionRepository _repository;

  FetchContributionConfigUseCase(this._repository);

  Future<Either<Failure, ContributionConfigEntity>> call({
    required String projectId,
  }) {
    return _repository.getContributionConfig(projectId);
  }
}
