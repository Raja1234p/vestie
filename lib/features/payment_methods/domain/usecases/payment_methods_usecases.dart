import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import '../repositories/payment_methods_repository.dart';

class ListPaymentMethodsUseCase {
  final PaymentMethodsRepository repository;

  ListPaymentMethodsUseCase(this.repository);

  Future<Either<Failure, List<PaymentCard>>> call({bool forceRefresh = false}) =>
      repository.list(forceRefresh: forceRefresh);
}

class SavePaymentCardUseCase {
  final PaymentMethodsRepository repository;

  SavePaymentCardUseCase(this.repository);

  Future<Either<Failure, PaymentCard>> call({
    required String holderName,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) =>
      repository.saveCardFromForm(
        holderName: holderName,
        cardNumber: cardNumber,
        expiry: expiry,
        cvv: cvv,
      );
}

class SetPrimaryPaymentMethodUseCase {
  final PaymentMethodsRepository repository;

  SetPrimaryPaymentMethodUseCase(this.repository);

  Future<Either<Failure, void>> call(String paymentMethodId) =>
      repository.setPrimary(paymentMethodId);
}

class RemovePaymentMethodUseCase {
  final PaymentMethodsRepository repository;

  RemovePaymentMethodUseCase(this.repository);

  Future<Either<Failure, void>> call(String paymentMethodId) =>
      repository.remove(paymentMethodId);
}
