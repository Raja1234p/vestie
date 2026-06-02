import 'package:dartz/dartz.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/constants/stripe_constants.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/stripe/stripe_payment_service.dart';
import 'package:vestie/core/utils/idempotency_key.dart';
import 'package:vestie/features/stripe/domain/usecases/get_stripe_config_use_case.dart';
import 'package:vestie/features/wallet/data/datasources/wallet_deposit_remote_data_source.dart';
import 'package:vestie/features/wallet/data/models/wallet_deposit_models.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_deposit_repository.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_repository.dart';

class WalletDepositRepositoryImpl implements WalletDepositRepository {
  final WalletDepositRemoteDataSource remoteDataSource;
  final WalletRepository walletRepository;
  final GetStripeConfigUseCase getStripeConfigUseCase;
  final StripePaymentService stripePaymentService;

  static const _pollInterval = Duration(seconds: 2);
  static const _pollTimeout = Duration(seconds: 90);

  WalletDepositRepositoryImpl({
    required this.remoteDataSource,
    required this.walletRepository,
    required this.getStripeConfigUseCase,
    required this.stripePaymentService,
  });

  @override
  Future<Either<Failure, DepositFlowOutcome>> runDepositFlow({
    required double amount,
    required String paymentMethodId,
  }) async {
    try {
      final configResult = await getStripeConfigUseCase();
      final config = configResult.fold(
        (failure) => throw failure,
        (config) => config,
      );

      final publishableKey = config.publishableKey.trim().isNotEmpty
          ? config.publishableKey.trim()
          : StripeConstants.publishableKey;

      await stripePaymentService.ensureInitialized(publishableKey);

      final idempotencyKey = newIdempotencyKey('deposit-intent');
      final intent = await remoteDataSource.createDepositIntent(
        amount: amount,
        paymentMethodId: paymentMethodId,
        idempotencyKey: idempotencyKey,
      );

      if (intent.clientSecret.trim().isEmpty && !intent.paymentAlreadyComplete) {
        return Right(
          DepositFlowOutcome(
            result: DepositFlowResult.failed,
            message: AppStrings.depositMissingClientSecret,
          ),
        );
      }

      if (!intent.paymentAlreadyComplete) {
        final paymentResult = await stripePaymentService.confirmDepositPayment(
          clientSecret: intent.clientSecret,
        );

        switch (paymentResult) {
          case StripeDepositPaymentResult.cancelled:
            return Right(
              DepositFlowOutcome(
                result: DepositFlowResult.cancelled,
                message: AppStrings.depositPaymentCancelled,
              ),
            );
          case StripeDepositPaymentResult.failed:
            return Right(
              DepositFlowOutcome(
                result: DepositFlowResult.failed,
                message: AppStrings.depositPaymentFailed,
              ),
            );
          case StripeDepositPaymentResult.completed:
            break;
        }
      }

      final outcome = await _pollUntilTerminal(intent.paymentIntentId);

      return Right(outcome);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  Future<DepositFlowOutcome> _pollUntilTerminal(String paymentIntentId) async {
    if (paymentIntentId.isEmpty) {
      return DepositFlowOutcome(
        result: DepositFlowResult.failed,
        message: AppStrings.depositMissingPaymentIntentId,
      );
    }

    final deadline = DateTime.now().add(_pollTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await remoteDataSource.getDepositStatus(paymentIntentId);
      switch (status.status) {
        case WalletDepositStatus.completed:
          return const DepositFlowOutcome(result: DepositFlowResult.completed);
        case WalletDepositStatus.failed:
          return DepositFlowOutcome(
            result: DepositFlowResult.failed,
            message: status.failureReason ?? AppStrings.depositPaymentFailed,
          );
        case WalletDepositStatus.cancelled:
          return DepositFlowOutcome(
            result: DepositFlowResult.cancelled,
            message: AppStrings.depositPaymentCancelled,
          );
        case WalletDepositStatus.aborted:
          return DepositFlowOutcome(
            result: DepositFlowResult.failed,
            message:
                status.failureReason ?? AppStrings.depositStatusAborted,
          );
        case WalletDepositStatus.exhausted:
          return DepositFlowOutcome(
            result: DepositFlowResult.failed,
            message:
                status.failureReason ?? AppStrings.depositStatusExhausted,
          );
        case WalletDepositStatus.pending:
        case WalletDepositStatus.unknown:
          await Future<void>.delayed(_pollInterval);
      }
    }
    return DepositFlowOutcome(
      result: DepositFlowResult.timeout,
      message: AppStrings.depositPollTimeout,
    );
  }
}
