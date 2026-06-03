import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/bank_account_entity.dart';
import '../entities/bank_link_result_entity.dart';

abstract class BankAccountsRepository {
  Future<Either<Failure, List<BankAccountEntity>>> list({
    bool forceRefresh = false,
  });

  Future<Either<Failure, BankLinkResultEntity>> link({
    String? bankAccountToken,
    String? refreshUrl,
    String? returnUrl,
  });

  Future<Either<Failure, void>> remove(String bankAccountId);

  Future<Either<Failure, void>> setDefault(
    String bankAccountId, {
    required bool isDefault,
  });
}
