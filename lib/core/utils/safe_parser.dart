extension SafeJsonParsing on Map<String, dynamic> {
  String safeString(String key, {String defaultValue = ''}) {
    if (this[key] == null) return defaultValue;
    return this[key].toString();
  }

  String? safeStringNullable(String key) {
    if (this[key] == null) return null;
    return this[key].toString();
  }

  int safeInt(String key, {int defaultValue = 0}) {
    if (this[key] == null) return defaultValue;
    if (this[key] is int) return this[key] as int;
    if (this[key] is double) return (this[key] as double).toInt();
    if (this[key] is String) return int.tryParse(this[key]) ?? defaultValue;
    return defaultValue;
  }

  double safeDouble(String key, {double defaultValue = 0.0}) {
    if (this[key] == null) return defaultValue;
    if (this[key] is double) return this[key] as double;
    if (this[key] is int) return (this[key] as int).toDouble();
    if (this[key] is String) return double.tryParse(this[key]) ?? defaultValue;
    return defaultValue;
  }

  bool safeBool(String key, {bool defaultValue = false}) {
    if (this[key] == null) return defaultValue;
    if (this[key] is bool) return this[key] as bool;
    if (this[key] is String) {
      final val = (this[key] as String).toLowerCase();
      return val == 'true' || val == '1';
    }
    if (this[key] is int) return this[key] == 1;
    return defaultValue;
  }

  DateTime? safeDateTimeUtc(String key) {
    if (this[key] == null) return null;
    if (this[key] is String) {
      final parsed = DateTime.tryParse(this[key] as String);
      return parsed?.isUtc == true ? parsed : parsed?.toUtc();
    }
    return null;
  }

  List<dynamic> safeList(String key) {
    if (this[key] == null) return [];
    if (this[key] is List) return this[key] as List<dynamic>;
    return [];
  }

  Map<String, dynamic> safeMap(String key) {
    if (this[key] == null) return {};
    if (this[key] is Map<String, dynamic>) return this[key] as Map<String, dynamic>;
    return {};
  }
}
