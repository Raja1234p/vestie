import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/account_deletion_eligibility_entity.dart';
import '../repositories/account_repository.dart';

class CheckAccountDeletionEligibilityUseCase {
  CheckAccountDeletionEligibilityUseCase(this._repository);

  final AccountRepository _repository;

  Future<Either<Failure, AccountDeletionEligibilityEntity>> call() =>
      _repository.getDeletionEligibility();
}
