import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/create_project_request_model.dart';
import '../models/create_project_response_model.dart';
import '../models/project_summary_model.dart';
import 'projects_remote_data_source.dart';

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final DioClient _client;

  ProjectsRemoteDataSourceImpl(this._client);

  bool _isConnectivityIssue(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.badCertificate:
        return true;
      case DioExceptionType.unknown:
        return e.response == null;
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return false;
    }
  }

  Never _handleError(DioException e, String defaultMessage) {
    if (_isConnectivityIssue(e)) {
      throw ServerException(AppStrings.errorNetwork);
    }

    String message = defaultMessage;
    String? title;

    if (e.response?.data != null && e.response?.data is Map) {
      final data = e.response!.data as Map;
      final fromErrors = _problemDetailsErrorsToMessage(data['errors']);
      message =
          data['detail']?.toString() ??
          data['message']?.toString() ??
          fromErrors ??
          (data['title'] != null && data['title'].toString().trim().isNotEmpty
              ? data['title'].toString()
              : null) ??
          defaultMessage;
      title = data['title']?.toString();
    }

    if (e.response?.statusCode == 401) {
      throw UnauthorizedException(message, title);
    }
    throw ServerException(message, title);
  }

  /// ASP.NET ProblemDetails: `errors` is `{ "FieldName": ["msg1", ...], ... }`.
  String? _problemDetailsErrorsToMessage(dynamic errors) {
    if (errors is! Map) return null;
    final lines = <String>[];
    for (final entry in errors.entries) {
      final field = entry.key.toString();
      final v = entry.value;
      if (v is List) {
        for (final item in v) {
          lines.add('$field: ${item.toString()}');
        }
      } else if (v != null) {
        lines.add('$field: ${v.toString()}');
      }
    }
    if (lines.isEmpty) return null;
    return lines.join('\n');
  }

  @override
  Future<List<ProjectSummaryModel>> listProjects({
    required String scope,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projects,
        queryParameters: {'scope': scope},
      );

      final data = response.data;
      if (data is! List) return const <ProjectSummaryModel>[];
      return data
          .whereType<Map>()
          .map(
            (m) => ProjectSummaryModel.fromJson(
              m.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
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
  Future<CreateProjectResponseModel> createProject({
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
      return CreateProjectResponseModel.fromJson(
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

  @override
  Future<void> launchProject(String projectId) async {
    try {
      await _client.post(ApiConstants.projectLaunch(projectId));
    } on DioException catch (e) {
      AppLogger.error(
        'API LaunchProject Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, AppStrings.errorLaunchProject);
    }
  }
}
