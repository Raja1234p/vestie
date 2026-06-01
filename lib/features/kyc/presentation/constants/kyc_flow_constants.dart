/// Deep-link style URLs passed to `POST /kyc/start` and matched when Stripe redirects.
class KycFlowConstants {
  KycFlowConstants._();

  static const String returnUrl = 'https://vestie.app/kyc/complete';
  static const String refreshUrl = 'https://vestie.app/kyc/refresh';

  static bool isCompletionOrRefreshUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith(returnUrl) || url.startsWith(refreshUrl);
  }
}
