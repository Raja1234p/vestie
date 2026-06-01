import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/project_pot_entity.dart';
import '../repositories/project_pot_repository.dart';

class GetProjectPotUseCase {
  final ProjectPotRepository repository;

  GetProjectPotUseCase(this.repository);

  Future<Either<Failure, ProjectPotEntity>> call(String projectId) =>
      repository.getPot(projectId);
}
