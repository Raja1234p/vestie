import 'package:dio/dio.dart';

import 'dio_interceptor_extras.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      int retries = err.requestOptions.extra[kRetriesExtraKey] as int? ?? 0;
      if (retries < maxRetries) {
        err.requestOptions.extra[kRetriesExtraKey] = retries + 1;
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Fall through to error
        }
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method != 'GET') return false;
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }
    if (err.response?.statusCode != null &&
        (err.response!.statusCode! >= 500)) {
      return true;
    }
    return false;
  }
}
