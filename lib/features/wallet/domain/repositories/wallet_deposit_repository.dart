import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';

enum DepositFlowResult { completed, failed, cancelled, timeout }

class DepositFlowOutcome {
  final DepositFlowResult result;
  final String? message;

  const DepositFlowOutcome({required this.result, this.message});
}

abstract class WalletDepositRepository {
  Future<Either<Failure, DepositFlowOutcome>> runDepositFlow({
    required double amount,
    required String paymentMethodId,
  });
}
