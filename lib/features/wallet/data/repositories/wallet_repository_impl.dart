import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/wallet/domain/entities/wallet_entity.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:vestie/features/wallet/domain/wallet_balance_cache.dart';

import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalletEntity>> getWallet({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = WalletBalanceCache.value;
      if (cached != null) return Right(cached);
    }
    try {
      final model = await remoteDataSource.getWallet();
      final entity = model.toEntity();
      WalletBalanceCache.update(entity);
      return Right(entity);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
