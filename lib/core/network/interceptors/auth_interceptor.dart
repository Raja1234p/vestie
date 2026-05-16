import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../constants/api_constants.dart';
import '../../constants/storage_keys.dart';
import '../../storage/secure_storage_impl.dart';
import '../../utils/logger.dart';

const _kAuthRetryExtraKey = 'auth_retry';

/// Injects Bearer token; on 401 refreshes via [ApiConstants.refreshToken] and retries once.
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorageImpl _secureStorage;

  AuthInterceptor({
    required Dio dio,
    required SecureStorageImpl secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getString(StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;
    if (_isAuthEndpoint(path) || err.requestOptions.extra[_kAuthRetryExtraKey] == true) {
      await _clearTokens();
      return handler.next(err);
    }

    final refreshToken =
        await _secureStorage.getString(StorageKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      AppLogger.error(
        'Auth refresh skipped: no refresh token in secure storage',
      );
      await _clearTokens();
      return handler.next(err);
    }

    try {
      AppLogger.info('Auth refresh: POST ${ApiConstants.refreshToken}');
      final tokens = await _refreshTokens(refreshToken);
      final newAccess = tokens.$1;
      final newRefresh = tokens.$2;

      if (newAccess == null || newAccess.isEmpty) {
        throw StateError('Refresh response missing accessToken');
      }

      await _secureStorage.saveString(StorageKeys.accessToken, newAccess);
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await _secureStorage.saveString(StorageKeys.refreshToken, newRefresh);
      }

      AppLogger.info('Auth refresh succeeded; retrying ${err.requestOptions.method} $path');

      final retryOptions = err.requestOptions;
      retryOptions.extra[_kAuthRetryExtraKey] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';

      final retryResponse = await _dio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } catch (e, stack) {
      AppLogger.error(
        'Auth refresh failed',
        error: e,
        stackTrace: stack,
      );
      await _clearTokens();
      return handler.next(err);
    }
  }

  static bool _isAuthEndpoint(String path) {
    return path == ApiConstants.refreshToken ||
        path == ApiConstants.login ||
        path == ApiConstants.googleLogin ||
        path == ApiConstants.appleLogin ||
        path == ApiConstants.verifyEmail ||
        path == ApiConstants.logout;
  }

  /// Returns (accessToken, refreshToken) from flat or `tokens`-wrapped JSON.
  static (String?, String?) _parseTokenPair(dynamic data) {
    if (data is! Map<String, dynamic>) return (null, null);
    final tokenData = data['tokens'] is Map<String, dynamic>
        ? data['tokens'] as Map<String, dynamic>
        : data;
    return (
      tokenData['accessToken'] as String?,
      tokenData['refreshToken'] as String?,
    );
  }

  Future<(String?, String?)> _refreshTokens(String refreshToken) async {
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: ApiConstants.requestTimeout,
        sendTimeout: ApiConstants.requestTimeout,
        receiveTimeout: ApiConstants.requestTimeout,
      ),
    );

    if (kDebugMode && refreshDio.httpClientAdapter is IOHttpClientAdapter) {
      (refreshDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
          () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    final refreshResponse = await refreshDio.post(
      ApiConstants.refreshToken,
      data: {
        'refreshToken': refreshToken,
        'deviceName': ApiConstants.defaultDeviceName,
        'ipAddress': ApiConstants.defaultIpAddress,
      },
    );

    return _parseTokenPair(refreshResponse.data);
  }

  Future<void> _clearTokens() async {
    await _secureStorage.remove(StorageKeys.accessToken);
    await _secureStorage.remove(StorageKeys.refreshToken);
  }
}
