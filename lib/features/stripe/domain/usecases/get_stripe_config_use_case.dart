import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/stripe_config_entity.dart';
import '../repositories/stripe_repository.dart';

class GetStripeConfigUseCase {
  final StripeRepository repository;

  GetStripeConfigUseCase(this.repository);

  Future<Either<Failure, StripeConfigEntity>> call({
    bool forceRefresh = false,
  }) => repository.getConfig(forceRefresh: forceRefresh);
}
