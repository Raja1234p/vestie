import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vestie/core/error/failures.dart';
import '../../data/models/contribution_submit_result_model.dart';
import '../../domain/repositories/contribution_repository.dart';

class ConfirmContributionUseCase {
  final ContributionRepository repository;

  ConfirmContributionUseCase(this.repository);

  Future<Either<Failure, ContributionSubmitResultModel>> call(
    ConfirmContributionParams params,
  ) async {
    return await repository.confirmContribution(
      projectId: params.projectId,
      membershipId: params.membershipId,
      walletId: params.walletId,
      amount: params.amount,
      currency: params.currency,
      externalReference: params.externalReference,
      confirmNonRefundable: params.confirmNonRefundable,
    );
  }
}

class ConfirmContributionParams extends Equatable {
  final String projectId;
  final String membershipId;
  final double amount;
  final String walletId;
  final String currency;
  final String? externalReference;
  final bool confirmNonRefundable;

  const ConfirmContributionParams({
    required this.projectId,
    required this.membershipId,
    required this.amount,
    required this.walletId,
    required this.currency,
    this.externalReference,
    required this.confirmNonRefundable,
  });

  @override
  List<Object?> get props => [
        projectId,
        membershipId,
        amount,
        walletId,
        currency,
        externalReference,
        confirmNonRefundable,
      ];
}
