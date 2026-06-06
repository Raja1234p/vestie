import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../auth/session_sign_out.dart';
import '../../constants/api_constants.dart';
import '../../constants/storage_keys.dart';
import '../../network/api_response_body.dart';
import '../../storage/secure_storage_impl.dart';
import '../../utils/logger.dart';

const _kAuthRetryExtraKey = 'auth_retry';

/// Injects Bearer token on every [DioClient] request.
///
/// On 401 from a protected endpoint: calls `POST /auth/refresh` once, saves new
/// tokens, retries the original request. Screens must not call the refresh API
/// manually — this interceptor handles it app-wide. Sign-out + login redirect
/// only when the refresh call itself fails (see [SessionSignOut]).
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorageImpl _secureStorage;

  AuthInterceptor({required Dio dio, required SecureStorageImpl secureStorage})
    : _dio = dio,
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

    final path = _normalizePath(err.requestOptions.path);

    // Retried once after a successful refresh — surface 401 to the caller only.
    if (err.requestOptions.extra[_kAuthRetryExtraKey] == true) {
      return handler.next(err);
    }

    // Public auth calls (login, verify, etc.) — never refresh or sign out.
    if (_skipsRefreshOn401(path)) {
      return handler.next(err);
    }

    // Refresh endpoint failed on the shared client — session is dead.
    if (path == ApiConstants.refreshToken) {
      await SessionSignOut.locally();
      return handler.next(err);
    }

    final refreshToken = await _secureStorage.getString(
      StorageKeys.refreshToken,
    );
    if (refreshToken == null || refreshToken.isEmpty) {
      AppLogger.error(
        'Auth refresh skipped: no refresh token in secure storage',
      );
      await SessionSignOut.locally();
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

      AppLogger.info(
        'Auth refresh succeeded; retrying ${err.requestOptions.method} $path',
      );

      final retryOptions = err.requestOptions;
      retryOptions.extra[_kAuthRetryExtraKey] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';

      try {
        final retryResponse = await _dio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      }
    } catch (e, stack) {
      AppLogger.error('Auth refresh failed', error: e, stackTrace: stack);
      await SessionSignOut.locally();
      return handler.next(err);
    }
  }

  static String _normalizePath(String path) {
    var p = path.trim();
    final uri = Uri.tryParse(p);
    if (uri != null && uri.path.isNotEmpty) {
      p = uri.path;
    }
    if (!p.startsWith('/')) p = '/$p';
    if (p.length > 1 && p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    return p;
  }

  static bool _skipsRefreshOn401(String path) {
    final p = _normalizePath(path);
    return p == ApiConstants.login ||
        p == ApiConstants.googleLogin ||
        p == ApiConstants.appleLogin ||
        p == ApiConstants.verifyEmail ||
        p == ApiConstants.logout;
  }

  @visibleForTesting
  static bool shouldSignOutOn401({
    required String path,
    required bool isAuthRetry,
  }) {
    if (isAuthRetry) return false;
    final p = _normalizePath(path);
    if (_skipsRefreshOn401(p)) return false;
    return p == ApiConstants.refreshToken;
  }

  /// Returns (accessToken, refreshToken) from flat or `tokens`-wrapped JSON.
  static (String?, String?) _parseTokenPair(dynamic data) {
    if (data is! Map) return (null, null);
    final map = unwrapApiResponseBody(Map<String, dynamic>.from(data));
    final tokenData = map['tokens'] is Map
        ? Map<String, dynamic>.from(map['tokens'] as Map)
        : map;
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
}
