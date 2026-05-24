import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import '../../domain/entities/user_me_summary_entity.dart';
import '../../domain/repositories/user_me_summary_repository.dart';
import '../datasources/user_me_summary_remote_data_source.dart';

class UserMeSummaryRepositoryImpl implements UserMeSummaryRepository {
  final UserMeSummaryRemoteDataSource remoteDataSource;

  UserMeSummaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserMeSummaryEntity>> getSummary() async {
    try {
      final model = await remoteDataSource.getSummary();
      return Right(model.toEntity());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
