import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/investment_returns_entities.dart';
import '../repositories/investment_returns_repository.dart';

class GetMyInvestmentReturnsUseCase {
  final InvestmentReturnsRepository repository;

  GetMyInvestmentReturnsUseCase(this.repository);

  Future<Either<Failure, MyInvestmentReturnsEntity>> call(String projectId) {
    return repository.getMyReturns(projectId);
  }
}

class GetInvestmentDistributionsUseCase {
  final InvestmentReturnsRepository repository;

  GetInvestmentDistributionsUseCase(this.repository);

  Future<Either<Failure, InvestmentDistributionsHistoryEntity>> call(
    String projectId,
  ) {
    return repository.getDistributions(projectId);
  }
}

class PreviewInvestmentDistributionUseCase {
  final InvestmentReturnsRepository repository;

  PreviewInvestmentDistributionUseCase(this.repository);

  Future<Either<Failure, InvestmentDistributionPreviewEntity>> call({
    required String projectId,
    required double amount,
  }) {
    return repository.previewDistribution(projectId: projectId, amount: amount);
  }
}

class ConfirmInvestmentDistributionUseCase {
  final InvestmentReturnsRepository repository;

  ConfirmInvestmentDistributionUseCase(this.repository);

  Future<Either<Failure, InvestmentDistributionResultEntity>> call({
    required String projectId,
    required double amount,
  }) {
    return repository.distribute(projectId: projectId, amount: amount);
  }
}
