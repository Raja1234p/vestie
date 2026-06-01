import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/bank_account_entity.dart';
import '../entities/bank_link_result_entity.dart';
import '../repositories/bank_accounts_repository.dart';

class ListBankAccountsUseCase {
  final BankAccountsRepository repository;

  ListBankAccountsUseCase(this.repository);

  Future<Either<Failure, List<BankAccountEntity>>> call({
    bool forceRefresh = false,
  }) =>
      repository.list(forceRefresh: forceRefresh);
}

class LinkBankAccountUseCase {
  final BankAccountsRepository repository;

  LinkBankAccountUseCase(this.repository);

  Future<Either<Failure, BankLinkResultEntity>> call({
    String? bankAccountToken,
    String? refreshUrl,
    String? returnUrl,
  }) =>
      repository.link(
        bankAccountToken: bankAccountToken,
        refreshUrl: refreshUrl,
        returnUrl: returnUrl,
      );
}

class RemoveBankAccountUseCase {
  final BankAccountsRepository repository;

  RemoveBankAccountUseCase(this.repository);

  Future<Either<Failure, void>> call(String bankAccountId) =>
      repository.remove(bankAccountId);
}
