import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/stripe/stripe_payment_service.dart';
import 'package:vestie/features/payment_methods/domain/payment_methods_cache.dart';
import 'package:vestie/features/payment_methods/domain/repositories/payment_methods_repository.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/stripe/domain/usecases/get_stripe_config_use_case.dart';

import '../datasources/payment_methods_remote_data_source.dart';

class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  final PaymentMethodsRemoteDataSource remoteDataSource;
  final GetStripeConfigUseCase getStripeConfigUseCase;
  final StripePaymentService stripePaymentService;

  PaymentMethodsRepositoryImpl({
    required this.remoteDataSource,
    required this.getStripeConfigUseCase,
    required this.stripePaymentService,
  });

  @override
  Future<Either<Failure, List<PaymentCard>>> list({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = PaymentMethodsCache.value;
      if (cached != null) return Right(cached);
    }
    try {
      final models = await remoteDataSource.list();
      final cards = models.map((m) => m.toCard()).toList(growable: false);
      PaymentMethodsCache.update(cards);
      return Right(cards);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PaymentCard>> getById(String paymentMethodId) async {
    try {
      final model = await remoteDataSource.getById(paymentMethodId);
      return Right(model.toCard());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PaymentCard>> saveCardFromForm({
    required String holderName,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    if (!kDebugMode) {
      return saveCardViaSetupIntent();
    }
    try {
      final model = await remoteDataSource.addCardDev(
        holderName: holderName,
        number: cardNumber,
        expiry: expiry,
        cvv: cvv,
      );
      PaymentMethodsCache.clear();
      return Right(model.toCard());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, PaymentCard>> saveCardViaSetupIntent() async {
    try {
      final configResult = await getStripeConfigUseCase();
      final config = configResult.fold(
        (failure) => throw failure,
        (config) => config,
      );

      if (config.publishableKey.trim().isEmpty) {
        return Left(ServerFailure(AppStrings.depositStripeNotConfigured));
      }

      await stripePaymentService.ensureInitialized(config.publishableKey);

      final setup = await remoteDataSource.createSetupIntent();
      if (setup.clientSecret.trim().isEmpty) {
        return Left(ServerFailure(AppStrings.addCardMissingClientSecret));
      }

      final paymentOutcome = await stripePaymentService.confirmSetupPayment(
        clientSecret: setup.clientSecret,
      );

      switch (paymentOutcome.result) {
        case StripeSetupPaymentResult.cancelled:
          return Left(ServerFailure(AppStrings.addCardStripeCancelled));
        case StripeSetupPaymentResult.failed:
          return Left(ServerFailure(AppStrings.addCardStripeFailed));
        case StripeSetupPaymentResult.completed:
          break;
      }

      final paymentMethodId = paymentOutcome.paymentMethodId?.trim() ?? '';
      if (paymentMethodId.isEmpty) {
        return Left(ServerFailure(AppStrings.addCardStripeFailed));
      }

      final model = await remoteDataSource.attachPaymentMethod(
        paymentMethodId: paymentMethodId,
      );
      PaymentMethodsCache.clear();
      return Right(model.toCard());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> setPrimary(String paymentMethodId) async {
    try {
      await remoteDataSource.setPrimary(paymentMethodId);
      PaymentMethodsCache.clear();
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String paymentMethodId) async {
    try {
      await remoteDataSource.remove(paymentMethodId);
      PaymentMethodsCache.clear();
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
