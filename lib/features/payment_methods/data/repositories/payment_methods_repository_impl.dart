import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/payment_methods/domain/payment_methods_cache.dart';
import 'package:vestie/features/payment_methods/domain/repositories/payment_methods_repository.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';

import '../datasources/payment_methods_remote_data_source.dart';
import '../models/payment_method_api_model.dart';

class PaymentMethodsRepositoryImpl implements PaymentMethodsRepository {
  final PaymentMethodsRemoteDataSource remoteDataSource;

  PaymentMethodsRepositoryImpl({required this.remoteDataSource});

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
    try {
      PaymentMethodApiModel model;
      if (kDebugMode) {
        try {
          model = await remoteDataSource.addCardDev(
            holderName: holderName,
            number: cardNumber,
            expiry: expiry,
            cvv: cvv,
          );
        } on Failure {
          rethrow;
        }
      } else {
        await remoteDataSource.createSetupIntent();
        return const Left(ServerFailure(
          'Card setup requires Stripe SDK integration. Use a test build for QA card entry.',
        ));
      }
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
