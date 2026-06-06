import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/project_detail_entity.dart';

abstract class ProjectDetailRepository {
  Future<Either<Failure, ProjectDetailEntity>> getProjectDetail({
    required String projectId,
  });
}
