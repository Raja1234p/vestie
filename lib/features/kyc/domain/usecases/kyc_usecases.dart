import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/kyc_status_entity.dart';
import '../repositories/kyc_repository.dart';

class GetKycStatusUseCase {
  final KycRepository repository;

  GetKycStatusUseCase(this.repository);

  Future<Either<Failure, KycStatusEntity>> call({bool forceRefresh = false}) =>
      repository.getStatus(forceRefresh: forceRefresh);
}

class StartKycUseCase {
  final KycRepository repository;

  StartKycUseCase(this.repository);

  Future<Either<Failure, KycStartResultEntity>> call({
    String country = 'US',
    String? refreshUrl,
    String? returnUrl,
  }) =>
      repository.startOnboarding(
        country: country,
        refreshUrl: refreshUrl,
        returnUrl: returnUrl,
      );
}
