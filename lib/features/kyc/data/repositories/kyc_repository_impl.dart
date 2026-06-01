import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/kyc/domain/entities/kyc_status_entity.dart';
import 'package:vestie/features/kyc/domain/kyc_status_cache.dart';
import 'package:vestie/features/kyc/domain/repositories/kyc_repository.dart';

import '../datasources/kyc_remote_data_source.dart';

class KycRepositoryImpl implements KycRepository {
  final KycRemoteDataSource remoteDataSource;

  KycRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, KycStatusEntity>> getStatus({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = KycStatusCache.value;
      if (cached != null) return Right(cached);
    }
    try {
      final model = await remoteDataSource.getStatus();
      KycStatusCache.update(model);
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, KycStartResultEntity>> startOnboarding({
    String country = 'US',
    String? refreshUrl,
    String? returnUrl,
  }) async {
    try {
      final model = await remoteDataSource.start(
        country: country,
        refreshUrl: refreshUrl,
        returnUrl: returnUrl,
      );
      KycStatusCache.clear();
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
