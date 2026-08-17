import 'package:dartz/dartz.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/stripe/domain/entities/stripe_processing_fee_entity.dart';
import 'package:vestie/features/stripe/domain/repositories/stripe_repository.dart';

class GetStripeProcessingFeeUseCase {
  GetStripeProcessingFeeUseCase(this.repository);

  final StripeRepository repository;

  Future<Either<Failure, StripeProcessingFeeEntity>> call({
    double? amount,
    String? paymentIntentId,
  }) {
    return repository.getProcessingFee(
      amount: amount,
      paymentIntentId: paymentIntentId,
    );
  }
}
