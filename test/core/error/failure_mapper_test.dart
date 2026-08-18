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

    test('409 with code/message body keeps server message', () {
      final failure = FailureMapper.fromDioException(
        DioException(
          requestOptions: RequestOptions(
            path: '/projects/p1/closure-voting/cancel',
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: '/projects/p1/closure-voting/cancel',
            ),
            statusCode: 409,
            data: {
              'code': 'VoteParticipationThresholdReached',
              'message':
                  'Continue contribution is no longer available because at least 50% of joined members have voted.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.title, 'VoteParticipationThresholdReached');
      expect(
        FailureMapper.userMessage(failure),
        'Continue contribution is no longer available because at least 50% of joined members have voted.',
      );
    });
  });
}
