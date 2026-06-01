import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/bank_account_entity.dart';

abstract class BankAccountsRepository {
  Future<Either<Failure, List<BankAccountEntity>>> list({
    bool forceRefresh = false,
  });

  Future<Either<Failure, void>> remove(String bankAccountId);
}
