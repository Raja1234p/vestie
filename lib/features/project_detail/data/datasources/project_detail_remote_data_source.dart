import '../../../../core/models/pagination_dto.dart';
import '../models/project_detail_response_model.dart';

abstract class ProjectDetailRemoteDataSource {
  Future<ProjectDetailResponseModel> getProjectDetail({
    required String projectId,
    int membersPage = PaginationQuery.defaultPage,
    int? membersPageSize,
    int announcementsPage = PaginationQuery.defaultPage,
    int? announcementsPageSize,
    int invitesPage = PaginationQuery.defaultPage,
    int? invitesPageSize,
  });
}
