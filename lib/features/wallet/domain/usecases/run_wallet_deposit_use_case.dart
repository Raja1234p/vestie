import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../repositories/wallet_deposit_repository.dart';

class RunWalletDepositUseCase {
  final WalletDepositRepository repository;

  RunWalletDepositUseCase(this.repository);

  Future<Either<Failure, DepositFlowOutcome>> call({
    required double amount,
    required String paymentMethodId,
  }) =>
      repository.runDepositFlow(
        amount: amount,
        paymentMethodId: paymentMethodId,
      );
}
