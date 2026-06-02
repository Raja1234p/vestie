/// Deep-link style URLs for `POST /bank-accounts` (browser onboarding).
class BankFlowConstants {
  BankFlowConstants._();

  static const String returnUrl = 'https://vestie.app/bank/return';
  static const String refreshUrl = 'https://vestie.app/bank/refresh';

  static bool isCompletionUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    final expected = Uri.tryParse(returnUrl);
    if (uri == null || expected == null) return false;
    return uri.scheme == expected.scheme &&
        uri.host == expected.host &&
        uri.path == expected.path;
  }

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
