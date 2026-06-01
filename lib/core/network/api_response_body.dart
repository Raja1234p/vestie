/// Normalizes API JSON that may be flat or wrapped (`value`, `data`, nested).
Map<String, dynamic> unwrapApiResponseBody(dynamic raw) {
  if (raw is! Map) return {};
  var map = Map<String, dynamic>.from(raw);

  for (var depth = 0; depth < 4; depth++) {
    final value = map['value'];
    if (value is Map) {
      map = Map<String, dynamic>.from(value);
      continue;
    }
    final data = map['data'];
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
      continue;
    }
    final result = map['result'];
    if (result is Map) {
      map = Map<String, dynamic>.from(result);
      continue;
    }
    break;
  }

  return map;
}
