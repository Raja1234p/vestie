import '../constants/api_constants.dart';

/// Normalizes create-invite API output into an HTTPS share link.
String resolveInviteShareLink(String apiValue) {
  final raw = apiValue.trim();
  if (raw.isEmpty) return '';

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  if (raw.startsWith('vestie://')) {
    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final code = _codeFromVestieUri(uri);
      if (code != null && code.isNotEmpty) {
        return ApiConstants.inviteShareUrl(code);
      }
    }
    return raw;
  }

  // Bare code, or path like /join/CODE or join/CODE
  final code = _extractInviteCode(raw);
  if (code.isEmpty) return '';
  return ApiConstants.inviteShareUrl(code);
}

String _extractInviteCode(String value) {
  final trimmed = value.trim();
  if (!trimmed.contains('/')) return trimmed;

  final uri = Uri.tryParse(
    trimmed.startsWith('http') ? trimmed : 'https://x/$trimmed',
  );
  if (uri == null) return trimmed;

  final segments =
      uri.pathSegments.where((s) => s.trim().isNotEmpty).toList();
  if (segments.length >= 2 && segments.first.toLowerCase() == 'join') {
    return segments[1];
  }
  return segments.isNotEmpty ? segments.last : trimmed;
}

String? _codeFromVestieUri(Uri uri) {
  if (uri.host.toLowerCase() == 'join') {
    final seg = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (seg.isNotEmpty) return seg.first;
  }
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length >= 2 && segments.first.toLowerCase() == 'join') {
    return segments[1];
  }
  return null;
}
