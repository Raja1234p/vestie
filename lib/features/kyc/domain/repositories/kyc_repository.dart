import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/kyc_status_entity.dart';

abstract class KycRepository {
  Future<Either<Failure, KycStatusEntity>> getStatus({bool forceRefresh = false});

  Future<Either<Failure, KycStartResultEntity>> startOnboarding({
    String country,
    String? refreshUrl,
    String? returnUrl,
  });
}
