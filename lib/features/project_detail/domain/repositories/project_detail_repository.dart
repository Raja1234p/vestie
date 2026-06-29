import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/pagination_dto.dart';
import '../entities/project_detail_entity.dart';

abstract class ProjectDetailRepository {
  Future<Either<Failure, ProjectDetailEntity>> getProjectDetail({
    required String projectId,
    int membersPage = PaginationQuery.defaultPage,
    int? membersPageSize,
    int announcementsPage = PaginationQuery.defaultPage,
    int? announcementsPageSize,
    int invitesPage = PaginationQuery.defaultPage,
    int? invitesPageSize,
  });
}
