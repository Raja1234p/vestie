/// Deep-link style URLs passed to `POST /kyc/start` and matched when Stripe redirects.
class KycFlowConstants {
  KycFlowConstants._();

  static const String returnUrl = 'https://vestie.app/kyc/complete';
  static const String refreshUrl = 'https://vestie.app/kyc/refresh';

  /// Stripe redirect when onboarding finished — close WebView, do not show landing page.
  static bool isCompletionUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    final expected = Uri.tryParse(returnUrl);
    if (uri == null || expected == null) return false;
    return uri.scheme == expected.scheme &&
        uri.host == expected.host &&
        uri.path == expected.path;
  }

  /// Stripe redirect when the session expired — fetch a new onboarding link.
  static bool isRefreshUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    final expected = Uri.tryParse(refreshUrl);
    if (uri == null || expected == null) return false;
    return uri.scheme == expected.scheme &&
        uri.host == expected.host &&
        uri.path == expected.path;
  }
}
