import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../utils/logger.dart';

/// Log tag for filtering in DevTools / `adb logcat` (debug builds only).
const _logTag = 'StripeOnboarding';

/// Opens Stripe hosted onboarding and returns to the app when the redirect
/// page sends the user to `vestie://…` (see [StripeConnectRedirectMatcher]).
///
/// Stripe still uses HTTPS `return_url` / `refresh_url` in API calls;
/// backend HTML at those paths must bounce to `vestie://` so the auth session
/// closes (plain HTTPS pages stay inside the browser on Android).
///
/// Uses [FlutterWebAuth2] 5.x (Chrome Auth Tab / ASWebAuthenticationSession).
class StripeHostedOnboardingLauncher {
  StripeHostedOnboardingLauncher._();

  /// Scheme the OS uses to resume the app after Stripe redirect pages.
  static const String callbackUrlScheme = 'vestie';

  /// Opens [onboardingUrl] and waits for `vestie://kyc/…` or `vestie://bank/…`.
  ///
  /// [httpsCompletionPath] is accepted for call-site compatibility but unused —
  /// iOS and Android both wait for `vestie://` (same as before deeplinking commits).
  ///
  /// Returns the callback URL, or `null` if the user closed the browser.
  static Future<String?> openAndWaitForRedirect(
    String onboardingUrl, {
    String? httpsCompletionPath,
  }) async {
    AppLogger.info(
      'Opening Stripe browser tab; waiting for $callbackUrlScheme:// redirect '
      '(backend must redirect HTTPS return pages to $callbackUrlScheme://)',
      name: _logTag,
    );
    AppLogger.debug('onboardingUrl=$onboardingUrl', name: _logTag);

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: onboardingUrl,
        callbackUrlScheme: callbackUrlScheme,
      );
      AppLogger.info(
        'Stripe browser closed with callback URL: $result',
        name: _logTag,
      );
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        AppLogger.info(
          'Stripe browser closed by user — no redirect URL',
          name: _logTag,
        );
        return null;
      }
      if (e.code == 'ACQUIRE_ROOT_VIEW_CONTROLLER_FAILED') {
        AppLogger.error(
          'iOS could not present Stripe browser (UIScene window not visible to '
          'flutter_web_auth_2). Rebuild after AppDelegate/SceneDelegate fix; '
          'use "Return to app" if the session still fails.',
          error: e,
          name: _logTag,
        );
        return null;
      }
      AppLogger.error(
        'FlutterWebAuth2 failed: ${e.code} ${e.message}',
        error: e,
        name: _logTag,
      );
      return null;
    } catch (e, st) {
      AppLogger.error(
        'FlutterWebAuth2 error',
        error: e,
        stackTrace: st,
        name: _logTag,
      );
      return null;
    }
  }
}
