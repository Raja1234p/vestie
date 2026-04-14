import 'dart:developer';
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('>>> [DIO] REQUEST[${options.method}] => PATH: ${options.path}');
    log('>>> [DIO] DATA: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('<<< [DIO] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    log('<<< [DIO] DATA: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('!!! [DIO] ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    log('!!! [DIO] MESSAGE: ${err.message}');
    super.onError(err, handler);
  }
}
