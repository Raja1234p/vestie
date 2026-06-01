import 'package:dio/dio.dart';

import '../error/failure_mapper.dart';
import '../error/failures.dart';

class BaseApiClient {
  final Dio dio;

  BaseApiClient({required this.dio});

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return _execute(() => dio.get<T>(path, queryParameters: queryParameters, options: options));
  }

  Future<T> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _execute(() => dio.post<T>(path, data: data, queryParameters: queryParameters, options: options));
  }

  Future<T> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _execute(() => dio.put<T>(path, data: data, queryParameters: queryParameters, options: options));
  }

  Future<T> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _execute(() => dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options));
  }

  Future<T> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return _execute(() => dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options));
  }

  Future<T> _execute<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as T;
      } else {
        throw ServerFailure();
      }
    } on DioException catch (e) {
      throw FailureMapper.fromDioException(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw FailureMapper.fromException(e);
    }
  }
}
