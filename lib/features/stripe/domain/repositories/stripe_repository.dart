import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/stripe_config_entity.dart';
import '../entities/stripe_processing_fee_entity.dart';

abstract class StripeRepository {
  Future<Either<Failure, StripeConfigEntity>> getConfig({
    bool forceRefresh = false,
  });

  Future<Either<Failure, StripeProcessingFeeEntity>> getProcessingFee({
    double? amount,
    String? paymentIntentId,
  });
}
