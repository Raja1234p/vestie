import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/stripe_config_entity.dart';

abstract class StripeRepository {
  Future<Either<Failure, StripeConfigEntity>> getConfig({bool forceRefresh = false});
}
