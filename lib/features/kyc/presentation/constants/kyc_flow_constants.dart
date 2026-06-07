import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/stripe/stripe_connect_redirect_matcher.dart';

/// Redirect URLs for `POST /kyc/start` — derived from [ApiConstants.baseUrl] host.
///
/// Stripe opens the HTTPS URLs. Backend pages at those paths must immediately
/// redirect to [appSchemeRefreshUrl] / [appSchemeReturnUrl] so Android closes
/// the browser tab and returns to the app (`vestie://` deep link).
class KycFlowConstants {
  KycFlowConstants._();

  static String get returnUrl => ApiConstants.kycReturnUrl;

  static String get refreshUrl => ApiConstants.kycRefreshUrl;

  static const String appSchemeReturnUrl = 'vestie://kyc/complete';
  static const String appSchemeRefreshUrl = 'vestie://kyc/refresh';

  static const String httpsCompletionPath = '/kyc/complete';

  static bool isCompletionUrl(String? url) {
    final uri = Uri.tryParse(url ?? '');
    if (uri != null &&
        StripeConnectRedirectMatcher.isVestieCompletion(uri, host: 'kyc')) {
      return true;
    }
    return StripeConnectRedirectMatcher.matchesAny(url, [
      returnUrl,
      appSchemeReturnUrl,
    ]);
  }

  static bool isRefreshUrl(String? url) {
    final uri = Uri.tryParse(url ?? '');
    if (uri != null &&
        StripeConnectRedirectMatcher.isVestieRefresh(uri, host: 'kyc')) {
      return true;
    }
    return StripeConnectRedirectMatcher.matchesAny(url, [
      refreshUrl,
      appSchemeRefreshUrl,
    ]);
  }
}
