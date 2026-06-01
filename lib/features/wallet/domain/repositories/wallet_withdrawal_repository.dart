import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/withdrawal_entities.dart';

class WithdrawFlowOutcome {
  final WithdrawalFlowStatus status;
  final String? message;

  const WithdrawFlowOutcome({required this.status, this.message});
}

abstract class WalletWithdrawalRepository {
  Future<Either<Failure, WithdrawalPreviewEntity>> preview({
    required double amount,
    required WithdrawalApiType type,
  });

  Future<Either<Failure, WithdrawFlowOutcome>> runWithdrawFlow({
    required double amount,
    required WithdrawalApiType type,
    required String bankAccountId,
  });
}
