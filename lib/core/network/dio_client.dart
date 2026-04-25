import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_impl.dart';

/// Enterprise-grade Network Client.
/// Upgraded to inject SecureStorageImpl into AuthInterceptor and bypass SSL for dev.
class DioClient {
  late final Dio _dio;

  DioClient({required SecureStorageImpl secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Bypass SSL certificate verification for development on real devices
    if (kDebugMode) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage),
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
