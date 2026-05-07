import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/contribution_repository.dart';

class ConfirmContributionUseCase {
  final ContributionRepository repository;

  ConfirmContributionUseCase(this.repository);

  Future<Either<Failure, void>> call(ConfirmContributionParams params) async {
    return await repository.confirmContribution(params.projectId, params.amount, params.walletId);
  }
}

class ConfirmContributionParams extends Equatable {
  final String projectId;
  final double amount;
  final String walletId;

  const ConfirmContributionParams({
    required this.projectId,
    required this.amount,
    required this.walletId,
  });

  @override
  List<Object?> get props => [projectId, amount, walletId];
}
