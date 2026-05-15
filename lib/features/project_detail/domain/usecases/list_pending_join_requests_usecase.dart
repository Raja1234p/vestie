import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pending_join_request_entity.dart';
import '../repositories/project_actions_repository.dart';

class ListPendingJoinRequestsUseCase {
  final ProjectActionsRepository _repository;

  ListPendingJoinRequestsUseCase(this._repository);

  Future<Either<Failure, List<PendingJoinRequestEntity>>> call(
    String projectId,
  ) {
    return _repository.listPendingJoinRequests(projectId);
  }
}
