import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../../domain/entities/investment_returns_entities.dart';
import '../../domain/repositories/investment_returns_repository.dart';
import '../datasources/investment_returns_remote_data_source.dart';

class InvestmentReturnsRepositoryImpl implements InvestmentReturnsRepository {
  final InvestmentReturnsRemoteDataSource remoteDataSource;

  InvestmentReturnsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MyInvestmentReturnsEntity>> getMyReturns(
    String projectId, {
    int historyPage = PaginationQuery.defaultPage,
    int? historyPageSize,
  }) async {
    return _execute(() async {
      final model = await remoteDataSource.getMyReturns(
        projectId,
        historyPage: historyPage,
        historyPageSize: historyPageSize,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, InvestmentDistributionsHistoryEntity>> getDistributions(
    String projectId, {
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    return _execute(() async {
      final model = await remoteDataSource.getDistributions(
        projectId,
        page: page,
        pageSize: pageSize,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, InvestmentDistributionPreviewEntity>>
  previewDistribution({
    required String projectId,
    required double amount,
  }) async {
    return _execute(() async {
      final model = await remoteDataSource.previewDistribution(
        projectId: projectId,
        amount: amount,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, InvestmentDistributionResultEntity>> distribute({
    required String projectId,
    required double amount,
  }) async {
    return _execute(() async {
      final model = await remoteDataSource.distribute(
        projectId: projectId,
        amount: amount,
      );
      return model.toEntity();
    });
  }

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
