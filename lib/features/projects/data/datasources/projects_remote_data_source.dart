import '../models/project_summary_model.dart';
import '../models/create_project_request_model.dart';

abstract class ProjectsRemoteDataSource {
  Future<List<ProjectSummaryModel>> listProjects({required String scope});

  Future<ProjectSummaryModel> createProject({
    required CreateProjectRequestModel request,
  });
}

