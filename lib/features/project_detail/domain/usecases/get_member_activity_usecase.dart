import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../entities/member_activity_entity.dart';
import '../repositories/project_actions_repository.dart';

class GetMemberActivityUseCase {
  final ProjectActionsRepository _repository;

  GetMemberActivityUseCase(this._repository);

  Future<Either<Failure, MemberActivityEntity>> call({
    required String projectId,
    required String userId,
    required String projectName,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  }) {
    return _repository.getMemberActivity(
      projectId: projectId,
      userId: userId,
      projectName: projectName,
      page: page,
      pageSize: pageSize,
    );
  }
}
