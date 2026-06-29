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
/// saves new tokens, retries the original request. Refresh is **reactive** (server
/// returned 401) — the client does not check JWT expiry before calling the API.
/// Concurrent 401s await the same refresh future; 401s handled after a peer refresh
/// reuse the stored access token instead of posting again. Sign-out only when refresh
/// itself fails.
class AuthInterceptor extends Interceptor {
  final Dio _retryDio;
  final SecureStorageImpl _secureStorage;
  final AuthTokenRefreshCoordinator _tokenRefresh;

  AuthInterceptor({
    required Dio dio,
    required SecureStorageImpl secureStorage,
    required AuthTokenRefreshCoordinator tokenRefresh,
    Dio? retryDio,
  }) : _retryDio = retryDio ?? _createRetryDio(dio),
       _secureStorage = secureStorage,
       _tokenRefresh = tokenRefresh;

  /// Retries bypass [AuthInterceptor] so a hung retry cannot block the 401 queue.
  static Dio _createRetryDio(Dio source) {
    return Dio(
      BaseOptions(
        baseUrl: source.options.baseUrl,
        connectTimeout: source.options.connectTimeout,
        sendTimeout: source.options.sendTimeout,
        receiveTimeout: source.options.receiveTimeout,
        headers: Map<String, dynamic>.from(source.options.headers),
      ),
    );
  }

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
      final failedBearer = _bearerFrom(err.requestOptions);
      final storedAccess = await _secureStorage.getString(
        StorageKeys.accessToken,
      );
      if (shouldRetryWithUpdatedAccessToken(
        failedBearer: failedBearer,
        storedAccess: storedAccess,
      )) {
        AppLogger.info(
          'Auth refresh skipped: retrying ${err.requestOptions.method} $path '
          'with updated access token',
        );
        return _retryWithAccessToken(
          err: err,
          accessToken: storedAccess!,
          handler: handler,
        );
      }

      AppLogger.info(
        'Auth refresh: server returned 401 on ${err.requestOptions.method} $path',
      );

      final newAccess = await _tokenRefresh.refresh(refreshToken);

      AppLogger.info(
        'Auth refresh retrying ${err.requestOptions.method} $path '
        '(after 401 — not a proactive expiry refresh)',
      );

      return _retryWithAccessToken(
        err: err,
        accessToken: newAccess,
        handler: handler,
      );
    } catch (e, stack) {
      AppLogger.error('Auth refresh failed', error: e, stackTrace: stack);
      await SessionSignOut.locally();
      return handler.next(err);
    }
  }

  Future<void> _retryWithAccessToken({
    required DioException err,
    required String accessToken,
    required ErrorInterceptorHandler handler,
  }) async {
    final retryOptions = err.requestOptions;
    retryOptions.extra[kAuthRetryExtraKey] = true;
    retryOptions.headers['Authorization'] = 'Bearer $accessToken';

    try {
      final retryResponse = await _retryDio.fetch(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    }
  }

  static String? _bearerFrom(RequestOptions options) {
    final raw =
        options.headers['Authorization'] ?? options.headers['authorization'];
    final auth = switch (raw) {
      final String s => s,
      final List<dynamic> list when list.isNotEmpty => list.first.toString(),
      _ => null,
    };
    if (auth == null) return null;
    const prefix = 'Bearer ';
    if (!auth.startsWith(prefix)) return null;
    final token = auth.substring(prefix.length).trim();
    return token.isEmpty ? null : token;
  }

  /// True when another 401 handler already refreshed and persisted a new token.
  @visibleForTesting
  static bool shouldRetryWithUpdatedAccessToken({
    required String? failedBearer,
    required String? storedAccess,
  }) {
    if (storedAccess == null || storedAccess.isEmpty) return false;
    if (failedBearer == null || failedBearer.isEmpty) return false;
    return storedAccess != failedBearer;
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
