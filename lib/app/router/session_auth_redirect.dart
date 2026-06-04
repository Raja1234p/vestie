import 'package:go_router/go_router.dart';

import '../../core/auth/app_auth_session.dart';
import 'app_routes.dart';

/// Sends signed-out users to login unless they are on a public auth route.
final class SessionAuthRedirect {
  SessionAuthRedirect._();

  static String? redirect(GoRouterState state) {
    return redirectForLocation(
      matchedLocation: state.matchedLocation,
      isAuthenticated: AppAuthSession.instance.isAuthenticated,
    );
  }

  /// Testable redirect without a live [GoRouterState].
  static String? redirectForLocation({
    required String matchedLocation,
    required bool isAuthenticated,
  }) {
    if (isAuthenticated) return null;
    if (_isExempt(matchedLocation)) return null;
    return AppRoutes.login;
  }

  static bool _isExempt(String location) {
    if (location == AppRoutes.splash) return true;

    return location == AppRoutes.onboarding ||
        location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.verify ||
        location == AppRoutes.forgotPassword ||
        location == AppRoutes.resetPassword ||
        location == AppRoutes.passwordUpdatedSuccess;
  }
}
