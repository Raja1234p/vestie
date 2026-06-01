import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/base_api_client.dart';

import '../models/project_pot_model.dart';

abstract class ProjectPotRemoteDataSource {
  Future<ProjectPotModel> getPot(String projectId);
}

class ProjectPotRemoteDataSourceImpl implements ProjectPotRemoteDataSource {
  final BaseApiClient apiClient;

  ProjectPotRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProjectPotModel> getPot(String projectId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.projectPot(projectId),
    );
    return ProjectPotModel.fromJson(response);
  }
}
