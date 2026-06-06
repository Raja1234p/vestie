import 'package:dio/dio.dart';

import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/core/network/dio_client.dart';
import 'package:vestie/core/utils/logger.dart';
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
      message =
          data['detail']?.toString() ??
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

  @override
  Future<void> approveBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      await _client.post(
        '${ApiConstants.projects}/$projectId/borrow-requests/$borrowRequestId/approve',
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API ApproveBorrowRequest Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to approve borrow request');
    }
  }

  @override
  Future<void> rejectBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      await _client.post(
        '${ApiConstants.projects}/$projectId/borrow-requests/$borrowRequestId/reject',
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API RejectBorrowRequest Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to reject borrow request');
    }
  }
}
