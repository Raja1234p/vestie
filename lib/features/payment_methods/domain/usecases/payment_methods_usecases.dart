import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import '../repositories/payment_methods_repository.dart';

class ListPaymentMethodsUseCase {
  final PaymentMethodsRepository repository;

  ListPaymentMethodsUseCase(this.repository);

  Future<Either<Failure, List<PaymentCard>>> call({
    bool forceRefresh = false,
  }) => repository.list(forceRefresh: forceRefresh);
}

class SavePaymentCardViaSetupUseCase {
  final PaymentMethodsRepository repository;

  SavePaymentCardViaSetupUseCase(this.repository);

  Future<Either<Failure, PaymentCard>> call({
    Future<void> Function()? onBeforePresentPaymentSheet,
  }) => repository.saveCardViaSetupIntent(
    onBeforePresentPaymentSheet: onBeforePresentPaymentSheet,
  );
}

class GetPaymentMethodUseCase {
  final PaymentMethodsRepository repository;

  GetPaymentMethodUseCase(this.repository);

  Future<Either<Failure, PaymentCard>> call(String paymentMethodId) =>
      repository.getById(paymentMethodId);
}

class SetPrimaryPaymentMethodUseCase {
  final PaymentMethodsRepository repository;

  SetPrimaryPaymentMethodUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String paymentMethodId, {
    required bool isPrimary,
  }) => repository.setPrimary(paymentMethodId, isPrimary: isPrimary);
}

class RemovePaymentMethodUseCase {
  final PaymentMethodsRepository repository;

  RemovePaymentMethodUseCase(this.repository);

  Future<Either<Failure, void>> call(String paymentMethodId) =>
      repository.remove(paymentMethodId);
}
