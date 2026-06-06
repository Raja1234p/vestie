/// Parses invite codes from `vestie.app/join/{code}` and related deep links.
String? parseProjectInviteCode(Uri uri) {
  final pathSegments = uri.pathSegments
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  if (pathSegments.length >= 2 && pathSegments.first.toLowerCase() == 'join') {
    return pathSegments[1];
  }

  if (uri.scheme == 'vestie') {
    if (uri.host.toLowerCase() == 'join') {
      if (pathSegments.isNotEmpty) return pathSegments.first;
      final fragment = uri.fragment.trim();
      if (fragment.isNotEmpty) return fragment;
    }
    if (pathSegments.length >= 2 &&
        pathSegments.first.toLowerCase() == 'join') {
      return pathSegments[1];
    }
  }

  return null;
}

bool isProjectInviteUri(Uri uri) => parseProjectInviteCode(uri) != null;
