import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_config_entity.dart';
import 'package:vestie/features/stripe/domain/repositories/stripe_repository.dart';
import 'package:vestie/features/stripe/domain/stripe_config_cache.dart';

import '../datasources/stripe_remote_data_source.dart';

class StripeRepositoryImpl implements StripeRepository {
  final StripeRemoteDataSource remoteDataSource;

  StripeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StripeConfigEntity>> getConfig({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = StripeConfigCache.value;
      if (cached != null) return Right(cached);
    }
    try {
      final model = await remoteDataSource.getConfig();
      StripeConfigCache.update(model);
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
