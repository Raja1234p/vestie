import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/account_deletion_eligibility_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({required this.remoteDataSource});

  final AccountRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, AccountDeletionEligibilityEntity>>
  getDeletionEligibility() async {
    try {
      final model = await remoteDataSource.getDeletionEligibility();
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({required bool confirmed}) async {
    try {
      await remoteDataSource.deleteAccount(confirmed: confirmed);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
