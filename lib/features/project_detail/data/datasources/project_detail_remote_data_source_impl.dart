import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/project_detail_response_model.dart';
import 'project_detail_remote_data_source.dart';

class ProjectDetailRemoteDataSourceImpl implements ProjectDetailRemoteDataSource {
  final DioClient _client;

  ProjectDetailRemoteDataSourceImpl(this._client);

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
  Future<ProjectDetailResponseModel> getProjectDetail({
    required String projectId,
  }) async {
    try {
      final response = await _client.get('${ApiConstants.projects}/$projectId');
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Invalid project detail response');
      }
      return ProjectDetailResponseModel.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API ProjectDetail Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load project');
    }
  }
}

