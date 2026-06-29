import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/investment_returns_entities.dart';

abstract class InvestmentReturnsRepository {
  Future<Either<Failure, MyInvestmentReturnsEntity>> getMyReturns(
    String projectId,
  );

  Future<Either<Failure, InvestmentDistributionsHistoryEntity>> getDistributions(
    String projectId,
  );

  Future<Either<Failure, InvestmentDistributionPreviewEntity>>
  previewDistribution({
    required String projectId,
    required double amount,
  });

  Future<Either<Failure, InvestmentDistributionResultEntity>> distribute({
    required String projectId,
    required double amount,
  });
}
