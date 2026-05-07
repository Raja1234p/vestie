import 'package:dio/dio.dart';
import '../error/failures.dart';
import '../models/api_error_response_model.dart';

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
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final apiError = ApiErrorResponseModel.fromJson(e.response!.data as Map<String, dynamic>);
        if (e.response!.statusCode == 400) {
          throw ValidationFailure(apiError.detail ?? apiError.title, null, apiError.errors);
        } else if (e.response!.statusCode == 401) {
           throw const UnauthorizedFailure();
        } else if (e.response!.statusCode == 403) {
           throw const ForbiddenFailure();
        }
        throw ServerFailure(apiError.detail ?? apiError.title);
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
         throw const TimeoutFailure();
      }
      throw const NetworkFailure();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
