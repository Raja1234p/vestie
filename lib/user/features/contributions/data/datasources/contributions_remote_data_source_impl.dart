import 'package:dio/dio.dart';

import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/error/exceptions.dart';
import 'package:vestie/core/network/dio_client.dart';
import 'package:vestie/core/utils/logger.dart';
import '../models/contribution_config_model.dart';
import '../models/contribution_confirm_model.dart';
import '../models/contribution_preview_model.dart';
import '../models/contribution_record_model.dart';
import 'contributions_remote_data_source.dart';

class ContributionsRemoteDataSourceImpl
    implements ContributionsRemoteDataSource {
  final DioClient _client;

  ContributionsRemoteDataSourceImpl(this._client);

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
  Future<ContributionConfigModel> getConfig({required String projectId}) async {
    try {
      final response = await _client.get(
        '${ApiConstants.contributions}/projects/$projectId/config',
      );
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Invalid contribution config response');
      }
      return ContributionConfigModel.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API ContributionConfig Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to load contribution config');
    }
  }

  @override
  Future<ContributionPreviewModel> preview({
    required ContributionRequest request,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.contributions}/preview',
        data: request.toJson(),
      );
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Invalid contribution preview response');
      }
      return ContributionPreviewModel.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API ContributionPreview Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to preview contribution');
    }
  }

  @override
  Future<ContributionConfirmModel> confirm({
    required ContributionRequest request,
  }) async {
    try {
      final response = await _client.post(
        '${ApiConstants.contributions}/confirm',
        data: request.toJson(),
      );
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Invalid contribution confirm response');
      }
      return ContributionConfirmModel.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      AppLogger.error(
        'API ContributionConfirm Error: ${e.response?.statusCode}',
        error: e.response?.data,
      );
      _handleError(e, 'Failed to confirm contribution');
    }
  }

  @override
  Future<List<ContributionRecordModel>> listByProject({
    required String projectId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.contributions,
        queryParameters: {'projectId': projectId},
      );
      final data = response.data;
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map(
            (e) => ContributionRecordModel.fromJson(e.cast<String, dynamic>()),
          )
          .toList(growable: false);
    } on DioException catch (e) {
      _handleError(e, 'Failed to load contribution list');
    }
  }

  @override
  Future<ContributionRecordModel> getById({required String id}) async {
    try {
      final response = await _client.get('${ApiConstants.contributions}/$id');
      final data = response.data;
      if (data is! Map) {
        throw ServerException('Invalid contribution detail response');
      }
      return ContributionRecordModel.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
    } on DioException catch (e) {
      _handleError(e, 'Failed to load contribution');
    }
  }

  @override
  Future<double> getProjectPotBalance({required String projectId}) async {
    try {
      final response = await _client.get(
        '${ApiConstants.contributions}/projects/$projectId/pot-balance',
      );
      final data = response.data;
      if (data is! Map) return 0;
      return (data['potBalance'] as num?)?.toDouble() ?? 0;
    } on DioException catch (e) {
      _handleError(e, 'Failed to load project pot balance');
    }
  }

  @override
  Future<double> getWalletAvailableBalance({required String walletId}) async {
    try {
      final response = await _client.get(
        '${ApiConstants.contributions}/wallets/$walletId/balance',
      );
      final data = response.data;
      if (data is! Map) return 0;
      return (data['availableBalance'] as num?)?.toDouble() ?? 0;
    } on DioException catch (e) {
      _handleError(e, 'Failed to load wallet balance');
    }
  }

  @override
  Future<String> awardVffBadge({required String projectId}) async {
    try {
      final response = await _client.post(
        '${ApiConstants.contributions}/projects/$projectId/award-vff-badge',
      );
      final data = response.data;
      if (data is! Map) return '';
      return data['message']?.toString() ?? '';
    } on DioException catch (e) {
      _handleError(e, 'Failed to award VFF badge');
    }
  }
}
