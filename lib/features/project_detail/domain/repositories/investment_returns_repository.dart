import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../entities/investment_returns_entities.dart';

abstract class InvestmentReturnsRepository {
  Future<Either<Failure, MyInvestmentReturnsEntity>> getMyReturns(
    String projectId, {
    int historyPage = PaginationQuery.defaultPage,
    int? historyPageSize,
  });

  Future<Either<Failure, InvestmentDistributionsHistoryEntity>> getDistributions(
    String projectId, {
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

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
