/// Matches Stripe Account Link redirects (`return_url` / `refresh_url`).
///
/// Mobile uses `vestie://` (opens the app via existing URL scheme).
/// `https://vestie.app/...` is also recognized when universal links are configured.
class StripeConnectRedirectMatcher {
  StripeConnectRedirectMatcher._();

  static bool matchesAny(String? url, List<String> canonicalUrls) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    for (final canonical in canonicalUrls) {
      if (_matches(uri, Uri.tryParse(canonical))) return true;
    }
    return false;
  }

  static bool _matches(Uri actual, Uri? expected) {
    if (expected == null) return false;
    return actual.scheme == expected.scheme &&
        actual.host == expected.host &&
        actual.port == expected.port &&
        actual.path == expected.path;
  }
}
