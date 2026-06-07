import 'package:vestie/core/constants/api_constants.dart';
import 'package:vestie/core/stripe/stripe_connect_redirect_matcher.dart';
import 'package:vestie/features/kyc/presentation/constants/kyc_flow_constants.dart';

/// Redirect URLs for `POST /bank-accounts`.
///
/// Uses the same HTTPS return/refresh pages as KYC (`/kyc/complete`, `/kyc/refresh`)
/// — those routes exist on the backend and are covered by AASA `/kyc/*`.
/// Backend bounce pages redirect to `vestie://kyc/complete` / `vestie://kyc/refresh`.
class BankFlowConstants {
  BankFlowConstants._();

  static String get returnUrl => ApiConstants.kycReturnUrl;

  static String get refreshUrl => ApiConstants.kycRefreshUrl;

  /// iOS auth-session HTTPS callback (same as [KycFlowConstants.httpsCompletionPath]).
  static const String httpsCompletionPath = KycFlowConstants.httpsCompletionPath;

  static bool isCompletionUrl(String? url) {
    if (KycFlowConstants.isCompletionUrl(url)) return true;

    final uri = Uri.tryParse(url ?? '');
    if (uri != null &&
        StripeConnectRedirectMatcher.isVestieCompletion(uri, host: 'bank')) {
      return true;
    }
    return StripeConnectRedirectMatcher.matchesAny(url, [
      'vestie://bank/return',
      ApiConstants.bankReturnUrl,
    ]);
  }

  static bool isRefreshUrl(String? url) {
    if (KycFlowConstants.isRefreshUrl(url)) return true;

    final uri = Uri.tryParse(url ?? '');
    if (uri != null &&
        StripeConnectRedirectMatcher.isVestieRefresh(uri, host: 'bank')) {
      return true;
    }
    return StripeConnectRedirectMatcher.matchesAny(url, [
      'vestie://bank/refresh',
      ApiConstants.bankRefreshUrl,
    ]);
  }
}
