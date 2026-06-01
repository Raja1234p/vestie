import 'package:dartz/dartz.dart';

import 'package:vestie/core/error/failures.dart';
import '../entities/project_pot_entity.dart';

abstract class ProjectPotRepository {
  Future<Either<Failure, ProjectPotEntity>> getPot(String projectId);
}
