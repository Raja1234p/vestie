import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/bank_accounts/domain/bank_accounts_cache.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_link_result_entity.dart';
import 'package:vestie/features/bank_accounts/domain/repositories/bank_accounts_repository.dart';

import '../datasources/bank_accounts_remote_data_source.dart';

class BankAccountsRepositoryImpl implements BankAccountsRepository {
  final BankAccountsRemoteDataSource remoteDataSource;

  BankAccountsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BankAccountEntity>>> list({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = BankAccountsCache.value;
      if (cached != null) return Right(cached);
    }
    try {
      final models = await remoteDataSource.list();
      BankAccountsCache.update(models);
      return Right(models);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, BankLinkResultEntity>> link({
    String? bankAccountToken,
    String? refreshUrl,
    String? returnUrl,
  }) async {
    try {
      final result = await remoteDataSource.link(
        bankAccountToken: bankAccountToken,
        refreshUrl: refreshUrl,
        returnUrl: returnUrl,
      );
      await list(forceRefresh: true);
      return Right(result);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
