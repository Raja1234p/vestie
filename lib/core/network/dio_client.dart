import 'package:dio/dio.dart';

import '../auth/auth_token_refresh_coordinator.dart';
import '../constants/api_constants.dart';
import '../device/device_info_service.dart';
import '../storage/secure_storage_impl.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Enterprise-grade Network Client.
/// Upgraded to inject SecureStorageImpl into AuthInterceptor and bypass SSL for dev.
class DioClient {
  late final Dio _dio;
  late final AuthTokenRefreshCoordinator _tokenRefresh;

  Dio get dio => _dio;

  DioClient({
    required SecureStorageImpl secureStorage,
    required DeviceInfoService deviceInfoService,
  }) {
    _tokenRefresh = AuthTokenRefreshCoordinator(
      secureStorage: secureStorage,
      deviceInfoService: deviceInfoService,
    );

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.requestTimeout,
        sendTimeout: ApiConstants.requestTimeout,
        receiveTimeout: ApiConstants.requestTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(
        dio: _dio,
        secureStorage: secureStorage,
        tokenRefresh: _tokenRefresh,
      ),
      RetryInterceptor(dio: _dio),
      LoggingInterceptor(),
    ]);
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
