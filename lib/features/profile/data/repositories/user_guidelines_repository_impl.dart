import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_guidelines_page.dart';
import '../../domain/repositories/user_guidelines_repository.dart';
import '../datasources/user_guidelines_remote_data_source.dart';

class UserGuidelinesRepositoryImpl implements UserGuidelinesRepository {
  UserGuidelinesRepositoryImpl({required this.remoteDataSource});

  final UserGuidelinesRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserGuidelinesPage>> getUserGuidelines() async {
    try {
      final model = await remoteDataSource.getUserGuidelines();
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
