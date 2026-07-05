import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../../domain/entities/project_funds_history_entity.dart';
import '../../domain/repositories/project_funds_history_repository.dart';
import '../datasources/project_funds_history_remote_data_source.dart';

class ProjectFundsHistoryRepositoryImpl
    implements ProjectFundsHistoryRepository {
  final ProjectFundsHistoryRemoteDataSource remoteDataSource;

  ProjectFundsHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProjectFundsHistoryEntity>> getFundsHistory({
    required String projectId,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) async {
    try {
      final model = await remoteDataSource.getFundsHistory(
        projectId: projectId,
        page: page,
        pageSize: pageSize,
      );
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
