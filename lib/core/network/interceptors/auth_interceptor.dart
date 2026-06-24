import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_token_refresh_coordinator.dart';
import '../../auth/session_sign_out.dart';
import '../../constants/api_constants.dart';
import '../../constants/storage_keys.dart';
import '../../storage/secure_storage_impl.dart';
import '../../utils/logger.dart';
import 'dio_interceptor_extras.dart';

/// Injects Bearer token on every [DioClient] request.
///
/// On 401 from a protected endpoint: coordinates a single `POST /auth/refresh`,
/// saves new tokens, retries the original request. Concurrent 401s await the same
/// refresh future. Sign-out only when refresh itself fails.
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorageImpl _secureStorage;
  final AuthTokenRefreshCoordinator _tokenRefresh;

  AuthInterceptor({
    required Dio dio,
    required SecureStorageImpl secureStorage,
    required AuthTokenRefreshCoordinator tokenRefresh,
  }) : _dio = dio,
       _secureStorage = secureStorage,
       _tokenRefresh = tokenRefresh;

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

    if (err.requestOptions.extra[kAuthRetryExtraKey] == true) {
      return handler.next(err);
    }

    if (_skipsRefreshOn401(path)) {
      return handler.next(err);
    }

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
      final newAccess = await _tokenRefresh.refresh(refreshToken);

      AppLogger.info(
        'Auth refresh retrying ${err.requestOptions.method} $path',
      );

      final retryOptions = err.requestOptions;
      retryOptions.extra[kAuthRetryExtraKey] = true;
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

  static bool willRefreshAndRetry401(DioException err) {
    if (err.response?.statusCode != 401) return false;
    if (err.requestOptions.extra[kAuthRetryExtraKey] == true) return false;
    final path = _normalizePath(err.requestOptions.path);
    if (_skipsRefreshOn401(path)) return false;
    if (path == ApiConstants.refreshToken) return false;
    return true;
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
}
