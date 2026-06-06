import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/contributions_repository.dart';
import '../value_objects/contribution_flow_models.dart';

class PreviewContributionUseCase {
  final ContributionsRepository _repository;

  PreviewContributionUseCase(this._repository);

  Future<Either<Failure, ContributionPreview>> call({
    required ContributionInput input,
  }) {
    return _repository.preview(input: input);
  }
}
