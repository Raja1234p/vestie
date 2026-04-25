import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../../constants/api_constants.dart';
import '../../constants/storage_keys.dart';
import '../../storage/secure_storage_impl.dart';

/// Enterprise-grade auth interceptor.
/// - Injects Bearer token on every request.
/// - On 401: silently refreshes via /auth/refresh and retries once.
/// - On refresh failure: clears tokens (user must re-login).
class AuthInterceptor extends Interceptor {
  final SecureStorageImpl _secureStorage;

  AuthInterceptor({required SecureStorageImpl secureStorage})
      : _secureStorage = secureStorage;

  // ── Inject token ──────────────────────────────────────────────────────────
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

  // ── Handle 401 — refresh + retry ─────────────────────────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken =
          await _secureStorage.getString(StorageKeys.refreshToken);

      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearTokens();
        return handler.next(err);
      }

      try {
        // Create a fresh Dio to avoid interceptor loop
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ));

        // Bypass SSL for refresh request in debug mode
        if (kDebugMode && refreshDio.httpClientAdapter is IOHttpClientAdapter) {
          (refreshDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
            final client = HttpClient();
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
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

        final data = refreshResponse.data as Map<String, dynamic>;
        final newAccess  = data['accessToken']  as String?;
        final newRefresh = data['refreshToken'] as String?;

        if (newAccess != null) {
          await _secureStorage.saveString(StorageKeys.accessToken, newAccess);
        }
        if (newRefresh != null) {
          await _secureStorage.saveString(StorageKeys.refreshToken, newRefresh);
        }

        // Retry original request with new token
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccess';

        final retryDio = Dio();
        if (kDebugMode && retryDio.httpClientAdapter is IOHttpClientAdapter) {
          (retryDio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
            final client = HttpClient();
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
            return client;
          };
        }

        final retryResponse = await retryDio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        // Refresh failed → clear tokens, propagate error
        await _clearTokens();
        return handler.next(err);
      }
    }
    handler.next(err);
  }

  Future<void> _clearTokens() async {
    await _secureStorage.remove(StorageKeys.accessToken);
    await _secureStorage.remove(StorageKeys.refreshToken);
  }
}
