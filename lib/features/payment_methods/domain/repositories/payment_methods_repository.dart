import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

abstract class PaymentMethodsRepository {
  Future<Either<Failure, List<PaymentCard>>> list({bool forceRefresh = false});

  Future<Either<Failure, PaymentCard>> getById(String paymentMethodId);

  Future<Either<Failure, PaymentCard>> saveCardFromForm({
    required String holderName,
    required String cardNumber,
    required String expiry,
    required String cvv,
  });

  /// Production add card: setup-intent → PaymentSheet → attach payment method.
  Future<Either<Failure, PaymentCard>> saveCardViaSetupIntent();

  Future<Either<Failure, void>> setPrimary(String paymentMethodId);

  Future<Either<Failure, void>> remove(String paymentMethodId);
}
