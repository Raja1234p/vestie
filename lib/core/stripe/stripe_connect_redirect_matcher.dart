/// Matches Stripe Account Link redirects (`return_url` / `refresh_url`).
///
/// App deep links: `vestie://kyc/complete`, `vestie://kyc/refresh`, `vestie://bank/return`, etc.
/// Backend HTTPS pages at [ApiConstants] paths must redirect to those `vestie://` URLs.
/// Paths accept both `/complete` and `complete` (normalized).
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

  /// `vestie` scheme + [host] + completion path (`/complete` or `/return`).
  static bool isVestieCompletion(Uri uri, {required String host}) =>
      uri.scheme == 'vestie' &&
      uri.host == host &&
      _pathEquals(uri.path, _completionPathForHost(host));

  /// `vestie` scheme + [host] + refresh path (`/refresh`).
  static bool isVestieRefresh(Uri uri, {required String host}) =>
      uri.scheme == 'vestie' &&
      uri.host == host &&
      _pathEquals(uri.path, '/refresh');

  static String _completionPathForHost(String host) =>
      host == 'bank' ? '/return' : '/complete';

  static bool _matches(Uri actual, Uri? expected) {
    if (expected == null) return false;
    return actual.scheme == expected.scheme &&
        actual.host == expected.host &&
        actual.port == expected.port &&
        _pathEquals(actual.path, expected.path);
  }

  static bool _pathEquals(String actual, String expected) =>
      _normalizePath(actual) == _normalizePath(expected);

  static String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    return path.startsWith('/') ? path : '/$path';
  }
}
