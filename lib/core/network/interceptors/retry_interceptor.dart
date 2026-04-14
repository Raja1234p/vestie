import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  
  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      var retries = err.requestOptions.extra['retries'] as int? ?? 0;
      if (retries < maxRetries) {
        retries++;
        err.requestOptions.extra['retries'] = retries;
        
        // Exponential backoff logic
        final delay = Duration(milliseconds: 1000 * retries);
        await Future.delayed(delay);

        try {
          // Retry the request
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return super.onError(e, handler);
        }
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    // Determine which exceptions shouldn't be retried
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.error is Exception; // generic network errors
  }
}
