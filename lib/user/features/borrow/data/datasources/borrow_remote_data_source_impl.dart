import 'package:dio/dio.dart';

import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/core/network/dio_client.dart';
import 'package:vestie/core/utils/logger.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import '../models/borrow_request_list_item_model.dart';
import '../models/borrow_request_model.dart';
import '../models/borrow_repay_models.dart';
import '../models/borrow_terms_model.dart';
import '../models/my_borrow_screen_model.dart';
import '../models/borrow_vote_result_model.dart';
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

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is! Map) {
      throw ServerException('Invalid borrow response');
    }
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  Future<BorrowTermsModel> getBorrowTerms({
    required String projectId,
    required double amount,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projectBorrowRequestTerms(projectId),
        queryParameters: {'amount': amount.toStringAsFixed(2)},
      );
      return BorrowTermsModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API GetBorrowTerms Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load borrow terms');
    }
  }

  @override
  Future<List<BorrowRequestEntity>> listBorrowRequests({
    required String projectId,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (status != null && status.trim().isNotEmpty) {
        query['status'] = status.trim();
      }

      final response = await _client.get(
        ApiConstants.projectBorrowRequests(projectId),
        queryParameters: query.isEmpty ? null : query,
      );

      final model = BorrowRequestListResponseModel.fromJson(
        _asMap(response.data),
      );
      return model.borrowRequests.map((item) => item.toEntity()).toList();
    } on DioException catch (e) {
      AppLogger.error(
        'API ListBorrowRequests Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load borrow requests');
    }
  }

  @override
  Future<BorrowVoteResultModel> voteBorrowRequest({
    required String projectId,
    required String borrowRequestId,
    required String vote,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.projectBorrowRequestVote(projectId, borrowRequestId),
        data: {'vote': vote},
      );
      return BorrowVoteResultModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API VoteBorrowRequest Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to submit vote');
    }
  }

  @override
  Future<BorrowRequestModel> createBorrowRequest({
    required String projectId,
    required CreateBorrowRequestBody body,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.projectBorrowRequests(projectId),
        data: body.toJson(),
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      return BorrowRequestModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API CreateBorrowRequest Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to submit borrow request');
    }
  }

  @override
  Future<MyBorrowScreenModel> getMyBorrowScreen({
    required String projectId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projectBorrowRequestsMineScreen(projectId),
      );
      return MyBorrowScreenModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API GetMyBorrowScreen Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load borrow request');
    }
  }

  @override
  Future<void> cancelBorrowRequest({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      await _client.post(
        ApiConstants.projectBorrowRequestCancel(projectId, borrowRequestId),
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API CancelBorrowRequest Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to cancel borrow request');
    }
  }

  @override
  Future<void> decideBorrowRequest({
    required String projectId,
    required String borrowRequestId,
    required String decision,
  }) async {
    try {
      await _client.post(
        ApiConstants.projectBorrowRequestDecide(projectId, borrowRequestId),
        data: {'decision': decision},
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API DecideBorrowRequest Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to decide borrow request');
    }
  }

  @override
  Future<List<MyBorrowCurrentRequestModel>> listMyBorrowRequests({
    required String projectId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projectBorrowRequestsMine(projectId),
      );
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((m) => MyBorrowCurrentRequestModel.fromJson(m.cast()))
          .toList(growable: false);
    } on DioException catch (e) {
      AppLogger.error(
        'API ListMyBorrowRequests Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load borrow history');
    }
  }

  @override
  Future<BorrowRepaySummaryModel> getBorrowRepaySummary({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projectBorrowRepay(projectId, borrowRequestId),
      );
      return BorrowRepaySummaryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API GetBorrowRepaySummary Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load borrow repayment');
    }
  }

  @override
  Future<BorrowRepayPaymentOptionsModel> getBorrowRepayPaymentOptions({
    required String projectId,
    required String borrowRequestId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projectBorrowRepayPaymentOptions(projectId, borrowRequestId),
      );
      return BorrowRepayPaymentOptionsModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API GetBorrowRepayPaymentOptions Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load payment options');
    }
  }

  @override
  Future<BorrowRepayPreviewModel> getBorrowRepayPreview({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
  }) async {
    try {
      final query = <String, dynamic>{'paymentSourceType': paymentSourceType};
      if (paymentMethodId != null && paymentMethodId.isNotEmpty) {
        query['paymentMethodId'] = paymentMethodId;
      }

      final response = await _client.get(
        ApiConstants.projectBorrowRepayPreview(projectId, borrowRequestId),
        queryParameters: query,
      );
      return BorrowRepayPreviewModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API GetBorrowRepayPreview Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load repayment preview');
    }
  }

  @override
  Future<BorrowRepaymentResultModel> submitBorrowRepayment({
    required String projectId,
    required String borrowRequestId,
    required String paymentSourceType,
    String? paymentMethodId,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.projectBorrowRepay(projectId, borrowRequestId),
        data: SubmitBorrowRepaymentBody(
          paymentSourceType: paymentSourceType,
          paymentMethodId: paymentMethodId,
          idempotencyKey: idempotencyKey,
        ).toJson(),
      );
      return BorrowRepaymentResultModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      AppLogger.error(
        'API SubmitBorrowRepayment Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to submit repayment');
    }
  }
}
