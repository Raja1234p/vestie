import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:vestie/core/error/failures.dart';
import '../../domain/entities/contribution_preview_entity.dart';
import '../../domain/repositories/contribution_repository.dart';

class PreviewContributionUseCase {
  final ContributionRepository repository;

  PreviewContributionUseCase(this.repository);

  Future<Either<Failure, ContributionPreviewEntity>> call(
    PreviewContributionParams params,
  ) async {
    return await repository.previewContribution(
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

class PreviewContributionParams extends Equatable {
  final String projectId;
  final String membershipId;
  final String walletId;
  final double amount;
  final String currency;
  final String? externalReference;
  final bool confirmNonRefundable;

  const PreviewContributionParams({
    required this.projectId,
    required this.membershipId,
    required this.walletId,
    required this.amount,
    required this.currency,
    this.externalReference,
    required this.confirmNonRefundable,
  });

  @override
  List<Object?> get props => [
    projectId,
    membershipId,
    walletId,
    amount,
    currency,
    externalReference,
    confirmNonRefundable,
  ];
}
