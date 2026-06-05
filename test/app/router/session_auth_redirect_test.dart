import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/session_auth_redirect.dart';

void main() {
  group('SessionAuthRedirect.redirectForLocation', () {
    test('redirects signed-out user on dashboard to login', () {
      expect(
        SessionAuthRedirect.redirectForLocation(
          matchedLocation: AppRoutes.dashboard,
          isAuthenticated: false,
        ),
        AppRoutes.login,
      );
    });

    test('allows splash while signed out', () {
      expect(
        SessionAuthRedirect.redirectForLocation(
          matchedLocation: AppRoutes.splash,
          isAuthenticated: false,
        ),
        isNull,
      );
    });

    test('allows login while signed out', () {
      expect(
        SessionAuthRedirect.redirectForLocation(
          matchedLocation: AppRoutes.login,
          isAuthenticated: false,
        ),
        isNull,
      );
    });

    test('redirects signed-out user on agreement to login', () {
      expect(
        SessionAuthRedirect.redirectForLocation(
          matchedLocation: AppRoutes.agreement,
          isAuthenticated: false,
        ),
        AppRoutes.login,
      );
    });

    test('allows agreement when authenticated', () {
      expect(
        SessionAuthRedirect.redirectForLocation(
          matchedLocation: AppRoutes.agreement,
          isAuthenticated: true,
        ),
        isNull,
      );
    });
  });
}
