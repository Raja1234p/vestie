import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/core/utils/idempotency_key.dart';
import 'package:vestie/features/wallet/data/datasources/wallet_withdrawal_remote_data_source.dart';
import 'package:vestie/features/wallet/domain/entities/withdrawal_entities.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:vestie/features/wallet/domain/repositories/wallet_withdrawal_repository.dart';

class WalletWithdrawalRepositoryImpl implements WalletWithdrawalRepository {
  final WalletWithdrawalRemoteDataSource remoteDataSource;
  final WalletRepository walletRepository;

  static const _pollInterval = Duration(seconds: 3);
  static const _pollTimeout = Duration(minutes: 5);

  WalletWithdrawalRepositoryImpl({
    required this.remoteDataSource,
    required this.walletRepository,
  });

  @override
  Future<Either<Failure, WithdrawalPreviewEntity>> preview({
    required double amount,
    required WithdrawalApiType type,
  }) async {
    try {
      final model = await remoteDataSource.preview(
        amount: amount,
        type: withdrawalTypeToApi(type),
      );
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, WithdrawFlowOutcome>> runWithdrawFlow({
    required double amount,
    required WithdrawalApiType type,
    required String bankAccountId,
  }) async {
    try {
      final submit = await remoteDataSource.submit(
        amount: amount,
        type: withdrawalTypeToApi(type),
        bankAccountId: bankAccountId,
        idempotencyKey: newIdempotencyKey('withdraw'),
      );

      final outcome = await _poll(submit.withdrawalId);
      if (outcome.status == WithdrawalFlowStatus.completed) {
        await walletRepository.getWallet(forceRefresh: true);
      }
      return Right(outcome);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  Future<WithdrawFlowOutcome> _poll(String withdrawalId) async {
    final deadline = DateTime.now().add(_pollTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await remoteDataSource.getStatus(withdrawalId);
      switch (status.status) {
        case WithdrawalFlowStatus.completed:
          return const WithdrawFlowOutcome(status: WithdrawalFlowStatus.completed);
        case WithdrawalFlowStatus.failed:
          return WithdrawFlowOutcome(
            status: WithdrawalFlowStatus.failed,
            message: status.failureReason ?? 'Withdrawal failed',
          );
        case WithdrawalFlowStatus.processing:
          await Future<void>.delayed(_pollInterval);
      }
    }
    return const WithdrawFlowOutcome(
      status: WithdrawalFlowStatus.processing,
      message: 'Still processing. Check your wallet shortly.',
    );
  }
}
