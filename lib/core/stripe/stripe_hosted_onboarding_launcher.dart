import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../constants/api_constants.dart';
import '../utils/logger.dart';

/// Log tag for filtering in DevTools / `adb logcat` (debug builds only).
const _logTag = 'StripeOnboarding';

/// Opens Stripe hosted onboarding and returns when Stripe hits the return URL.
///
/// **Android** — unchanged: waits for `vestie://bank/return` / `vestie://kyc/complete`
/// (same as before; requires backend redirect from HTTPS return pages).
///
/// **iOS 17.4+** — HTTPS callback on the same return path sent to the API
/// (bank and kyc both use `/kyc/complete` on the API host for bank link).
///
/// **Older iOS** — same as Android (`vestie://` redirect from backend).
class StripeHostedOnboardingLauncher {
  StripeHostedOnboardingLauncher._();

  static const String callbackUrlScheme = 'vestie';

  static Future<String?> openAndWaitForRedirect(
    String onboardingUrl, {
    required String httpsCompletionPath,
  }) async {
    final useHttpsCallback = _shouldUseHttpsCallback();
    AppLogger.info(
      useHttpsCallback
          ? 'Opening Stripe browser; HTTPS callback '
              'https://${ApiConstants.stripeRedirectHost}$httpsCompletionPath'
          : 'Opening Stripe browser; waiting for $callbackUrlScheme:// redirect',
      name: _logTag,
    );
    AppLogger.debug('onboardingUrl=$onboardingUrl', name: _logTag);

    try {
      final result = useHttpsCallback
          ? await FlutterWebAuth2.authenticate(
              url: onboardingUrl,
              callbackUrlScheme: 'https',
              options: FlutterWebAuth2Options(
                httpsHost: ApiConstants.stripeRedirectHost,
                httpsPath: httpsCompletionPath,
              ),
            )
          : await FlutterWebAuth2.authenticate(
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
          'iOS could not present Stripe browser — use "Return to app".',
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

  /// HTTPS callback is iOS-only so Android keeps the proven `vestie://` path.
  static bool _shouldUseHttpsCallback() {
    if (!Platform.isIOS) return false;
    return isIos174OrNewer(_iosSystemVersion());
  }

  static String _iosSystemVersion() {
    final raw = Platform.operatingSystemVersion;
    final match = RegExp(r'(\d+)\.(\d+)').firstMatch(raw);
    if (match == null) return raw;
    return '${match.group(1)}.${match.group(2)}';
  }

  /// iOS 17.4+ supports HTTPS callbacks in `ASWebAuthenticationSession`.
  static bool isIos174OrNewer(String systemVersion) {
    final segments = systemVersion.split('.');
    final major = int.tryParse(segments.first) ?? 0;
    final minor = segments.length > 1 ? int.tryParse(segments[1]) ?? 0 : 0;
    return major > 17 || (major == 17 && minor >= 4);
  }
}
