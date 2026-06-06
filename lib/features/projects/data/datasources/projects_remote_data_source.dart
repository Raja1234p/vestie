import '../models/create_project_request_model.dart';
import '../models/create_project_response_model.dart';
import '../models/project_summary_model.dart';

abstract class ProjectsRemoteDataSource {
  Future<List<ProjectSummaryModel>> listProjects({required String scope});

  Future<CreateProjectResponseModel> createProject({
    required CreateProjectRequestModel request,
  });

  /// `POST /projects/{id}/launch` — activates a draft project (leader only).
  Future<void> launchProject(String projectId);
}
