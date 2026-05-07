import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/join_project_result_entity.dart';
import '../repositories/project_repository.dart';

class JoinProjectUseCase {
  final ProjectRepository repository;

  JoinProjectUseCase(this.repository);

  Future<Either<Failure, JoinProjectResultEntity>> call({
    required String projectId,
    required String inviteCode,
  }) async {
    return repository.joinProject(
      projectId: projectId,
      inviteCode: inviteCode,
    );
  }
}

