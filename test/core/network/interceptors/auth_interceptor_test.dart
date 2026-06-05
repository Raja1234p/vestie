import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/network/interceptors/auth_interceptor.dart';

void main() {
  group('AuthInterceptor.shouldSignOutOn401', () {
    test('does not sign out when request was already retried after refresh', () {
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: '/projects/1',
          isAuthRetry: true,
        ),
        isFalse,
      );
    });

    test('does not sign out for login or verify failures', () {
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: ApiConstants.login,
          isAuthRetry: false,
        ),
        isFalse,
      );
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: ApiConstants.verifyEmail,
          isAuthRetry: false,
        ),
        isFalse,
      );
    });

    test('does not sign out for normal API 401 before refresh attempt', () {
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: '/projects/1',
          isAuthRetry: false,
        ),
        isFalse,
      );
    });

    test('signs out when refresh endpoint returns 401', () {
      expect(
        AuthInterceptor.shouldSignOutOn401(
          path: ApiConstants.refreshToken,
          isAuthRetry: false,
        ),
        isTrue,
      );
    });
  });
}
