import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/create_project_request_model.dart';
import '../models/project_summary_model.dart';
import 'projects_remote_data_source.dart';

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final DioClient _client;

  ProjectsRemoteDataSourceImpl(this._client);

  Never _handleError(DioException e, String defaultMessage) {
    String message = defaultMessage;
    String? title;

    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map;
      message = data['detail']?.toString() ??
          data['message']?.toString() ??
          defaultMessage;
      title = data['title']?.toString();
    }

    if (e.response?.statusCode == 401) {
      throw UnauthorizedException(message, title);
    }
    throw ServerException(message, title);
  }

  @override
  Future<List<ProjectSummaryModel>> listProjects({required String scope}) async {
    try {
      final response = await _client.get(
        ApiConstants.projects,
        queryParameters: {'scope': scope},
      );

      final data = response.data;
      if (data is! List) return const <ProjectSummaryModel>[];
      return data
          .whereType<Map>()
          .map((m) => ProjectSummaryModel.fromJson(
                m.map((k, v) => MapEntry(k.toString(), v)),
              ))
          .toList(growable: false);
    } on DioException catch (e) {
      AppLogger.error(
        'API ListProjects Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load projects');
    }
  }

  @override
  Future<ProjectSummaryModel> createProject({
    required CreateProjectRequestModel request,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.projects,
        data: request.toJson(),
      );
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Invalid create project response');
      }
      return ProjectSummaryModel.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API CreateProject Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to create project');
    }
  }
}

