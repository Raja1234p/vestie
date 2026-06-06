import '../models/project_detail_response_model.dart';

abstract class ProjectDetailRemoteDataSource {
  Future<ProjectDetailResponseModel> getProjectDetail({
    required String projectId,
  });
}
