import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/contributions_repository.dart';
import '../value_objects/contribution_flow_models.dart';

class ConfirmContributionUseCase {
  final ContributionsRepository _repository;

  ConfirmContributionUseCase(this._repository);

  Future<Either<Failure, ContributionResult>> call({
    required ContributionInput input,
  }) {
    return _repository.confirm(input: input);
  }
}
