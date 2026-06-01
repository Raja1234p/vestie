import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';
import 'package:vestie/features/project_pot/domain/entities/project_pot_entity.dart';
import 'package:vestie/features/project_pot/domain/repositories/project_pot_repository.dart';

import '../datasources/project_pot_remote_data_source.dart';

class ProjectPotRepositoryImpl implements ProjectPotRepository {
  final ProjectPotRemoteDataSource remoteDataSource;

  ProjectPotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProjectPotEntity>> getPot(String projectId) async {
    try {
      final model = await remoteDataSource.getPot(projectId);
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
