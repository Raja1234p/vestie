import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/stripe/stripe_connect_redirect_matcher.dart';

/// Redirect URLs for `POST /bank-accounts` — derived from [ApiConstants.baseUrl] host.
class BankFlowConstants {
  BankFlowConstants._();

  static String get returnUrl => ApiConstants.bankReturnUrl;

  static String get refreshUrl => ApiConstants.bankRefreshUrl;

  static const String appSchemeReturnUrl = 'vestie://bank/return';
  static const String appSchemeRefreshUrl = 'vestie://bank/refresh';

  static bool isCompletionUrl(String? url) => StripeConnectRedirectMatcher.matchesAny(
        url,
        [returnUrl, appSchemeReturnUrl],
      );

  static bool isRefreshUrl(String? url) => StripeConnectRedirectMatcher.matchesAny(
        url,
        [refreshUrl, appSchemeRefreshUrl],
      );
}
