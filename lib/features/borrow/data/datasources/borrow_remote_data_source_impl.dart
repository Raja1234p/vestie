import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/borrow_request_model.dart';
import 'borrow_remote_data_source.dart';

class BorrowRemoteDataSourceImpl implements BorrowRemoteDataSource {
  final DioClient _client;

  BorrowRemoteDataSourceImpl(this._client);

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
  Future<BorrowRequestModel> createBorrowRequest({
    required String projectId,
    required CreateBorrowRequestBody body,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.projects}/$projectId/borrow-requests',
        data: body.toJson(),
      );
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Invalid borrow request response');
      }
      return BorrowRequestModel.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API CreateBorrowRequest Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to submit borrow request');
    }
  }
}

