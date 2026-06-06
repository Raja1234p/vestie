import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/error/failures.dart';

void main() {
  group('FailureMapper.fromDioException', () {
    test('401 with API body maps to UnauthorizedFailure', () {
      final failure = FailureMapper.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/projects/join'),
          response: Response(
            requestOptions: RequestOptions(path: '/projects/join'),
            statusCode: 401,
            data: {
              'title': 'Authentication failed',
              'status': 401,
              'detail': 'Invalid or expired token.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(FailureMapper.userMessage(failure), 'Invalid or expired token.');
    });

    test('401 with empty body maps to session expired, not network', () {
      final failure = FailureMapper.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/projects/join'),
          response: Response(
            requestOptions: RequestOptions(path: '/projects/join'),
            statusCode: 401,
            data: '',
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure, isA<UnauthorizedFailure>());
      expect(FailureMapper.userMessage(failure), AppStrings.errorUnauthorized);
      expect(failure, isNot(isA<NetworkFailure>()));
    });

    test('connection error without response maps to NetworkFailure', () {
      final failure = FailureMapper.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: '/projects/join'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(failure, isA<NetworkFailure>());
    });
  });
}
