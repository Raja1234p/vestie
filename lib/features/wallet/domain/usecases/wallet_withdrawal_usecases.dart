import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/withdrawal_entities.dart';
import '../repositories/wallet_withdrawal_repository.dart';

class PreviewWithdrawalUseCase {
  final WalletWithdrawalRepository repository;

  PreviewWithdrawalUseCase(this.repository);

  Future<Either<Failure, WithdrawalPreviewEntity>> call({
    required double amount,
    required WithdrawalApiType type,
  }) =>
      repository.preview(amount: amount, type: type);
}

class RunWalletWithdrawUseCase {
  final WalletWithdrawalRepository repository;

  RunWalletWithdrawUseCase(this.repository);

  Future<Either<Failure, WithdrawFlowOutcome>> call({
    required double amount,
    required WithdrawalApiType type,
    required String bankAccountId,
  }) =>
      repository.runWithdrawFlow(
        amount: amount,
        type: type,
        bankAccountId: bankAccountId,
      );
}
