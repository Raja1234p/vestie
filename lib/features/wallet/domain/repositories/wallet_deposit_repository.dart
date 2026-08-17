import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';

enum DepositFlowResult { completed, failed, cancelled, timeout }

class DepositFlowOutcome {
  final DepositFlowResult result;
  final String? message;
  final String? paymentIntentId;

  const DepositFlowOutcome({
    required this.result,
    this.message,
    this.paymentIntentId,
  });
}

abstract class WalletDepositRepository {
  Future<Either<Failure, DepositFlowOutcome>> runDepositFlow({
    required double amount,
    required String paymentMethodId,
  });
}
