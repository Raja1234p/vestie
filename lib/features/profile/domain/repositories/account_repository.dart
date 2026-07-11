import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/account_deletion_eligibility_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, AccountDeletionEligibilityEntity>>
  getDeletionEligibility();

  Future<Either<Failure, void>> deleteAccount({required bool confirmed});
}
