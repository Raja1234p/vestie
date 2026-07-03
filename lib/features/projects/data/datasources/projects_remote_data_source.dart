import '../../../../core/models/pagination_dto.dart';
import '../models/create_project_request_model.dart';
import '../models/create_project_response_model.dart';
import '../models/project_summary_model.dart';

abstract class ProjectsRemoteDataSource {
  Future<PaginatedListModel<ProjectSummaryModel>> listProjects({
    required String scope,
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<PaginatedListModel<ProjectSummaryModel>> listCompletedProjects({
    int page = PaginationQuery.defaultPage,
    int? pageSize,
  });

  Future<CreateProjectResponseModel> createProject({
    required CreateProjectRequestModel request,
  });

  /// `POST /projects/{id}/launch` — activates a draft project (leader only).
  Future<void> launchProject(String projectId);

  /// `PUT /projects/{id}` — leader updates project settings.
  Future<void> updateProject({
    required String projectId,
    required CreateProjectRequestModel request,
  });
}
