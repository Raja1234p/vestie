/// Deep-link style URLs for `POST /bank-accounts` (browser onboarding).
class BankFlowConstants {
  BankFlowConstants._();

  static const String returnUrl = 'https://vestie.app/bank/return';
  static const String refreshUrl = 'https://vestie.app/bank/refresh';

  static bool isCompletionOrRefreshUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith(returnUrl) || url.startsWith(refreshUrl);
  }
}
