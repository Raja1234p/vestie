import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/logger.dart';

/// Log tag for filtering in DevTools / `adb logcat` (debug builds only).
const _logTag = 'StripeOnboarding';

/// Opens Stripe hosted onboarding and returns to the app when the redirect
/// page sends the user to `vestie://…` (see [StripeConnectRedirectMatcher]).
///
/// Stripe still uses HTTPS `return_url` / `refresh_url` in `POST /kyc/start`;
/// backend HTML at those paths must bounce to `vestie://` so the Custom Tab
/// closes (plain HTTPS pages stay inside the browser on Android).
///
/// Uses [FlutterWebAuth2] (Chrome Custom Tab / SFSafariViewController).
class StripeHostedOnboardingLauncher {
  StripeHostedOnboardingLauncher._();

  /// Scheme the OS uses to resume the app after Stripe redirect pages.
  static const String callbackUrlScheme = 'vestie';

  /// Opens [onboardingUrl] and waits for `vestie://kyc/…` or `vestie://bank/…`.
  ///
  /// Returns the callback URL, or `null` if the user closed the browser.
  /// Throws on launch failure.
  static Future<String?> openAndWaitForRedirect(String onboardingUrl) async {
    AppLogger.info(
      'Opening Stripe browser tab; waiting for $callbackUrlScheme:// redirect '
      '(backend must redirect HTTPS /kyc/* pages to $callbackUrlScheme://)',
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
          'Stripe browser closed by user (back/close) — no redirect URL '
          '(Return link may have shown 404 if backend routes are missing)',
          name: _logTag,
        );
        return null;
      }
      AppLogger.error(
        'FlutterWebAuth2 failed: ${e.code} ${e.message}',
        error: e,
        name: _logTag,
      );
      return _openWithUrlLauncherFallback(onboardingUrl);
    } catch (e, st) {
      AppLogger.error(
        'FlutterWebAuth2 error; using url_launcher fallback',
        error: e,
        stackTrace: st,
        name: _logTag,
      );
      return _openWithUrlLauncherFallback(onboardingUrl);
    }
  }

  /// User must return manually; no callback URL.
  static Future<void> openExternal(String onboardingUrl) async {
    final uri = Uri.parse(onboardingUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (!ok) {
      throw Exception('Could not open browser');
    }
  }

  static Future<String?> _openWithUrlLauncherFallback(String onboardingUrl) async {
    AppLogger.info(
      'Opened Stripe in external browser — app will not auto-capture Return redirect',
      name: _logTag,
    );
    await openExternal(onboardingUrl);
    return null;
  }
}
