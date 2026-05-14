/// Maps API enum integers to the string labels used in [ProjectSummaryEntity]
/// and home [Project] mapping (see [ProjectsRepositoryImpl._mapCategory]).
String projectTypeApiValueToSummaryString(dynamic raw) {
  if (raw == null) return '';
  if (raw is double) return projectTypeApiValueToSummaryString(raw.toInt());
  if (raw is int) {
    return switch (raw) {
      1 => 'Vacation',
      2 => 'Emergency',
      3 => 'Investment',
      _ => raw.toString(),
    };
  }
  final s = raw.toString().trim();
  if (s.isEmpty) return '';
  final asInt = int.tryParse(s);
  if (asInt != null) return projectTypeApiValueToSummaryString(asInt);
  return s;
}

String projectVisibilityApiValueToSummaryString(dynamic raw) {
  if (raw == null) return '';
  if (raw is double) return projectVisibilityApiValueToSummaryString(raw.toInt());
  if (raw is int) {
    return switch (raw) {
      1 => 'Public',
      2 => 'Private',
      _ => raw.toString(),
    };
  }
  final s = raw.toString().trim();
  if (s.isEmpty) return '';
  final asInt = int.tryParse(s);
  if (asInt != null) return projectVisibilityApiValueToSummaryString(asInt);
  return s;
}

String projectStateApiValueToSummaryString(dynamic raw) {
  if (raw == null) return '';
  if (raw is double) return projectStateApiValueToSummaryString(raw.toInt());
  if (raw is int) {
    return switch (raw) {
      0 => 'Draft',
      1 => 'Active',
      _ => 'State$raw',
    };
  }
  final s = raw.toString().trim();
  if (s.isEmpty) return '';
  final asInt = int.tryParse(s);
  if (asInt != null) return projectStateApiValueToSummaryString(asInt);
  return s;
}

int? projectTypeToApiInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is double) return raw.toInt();
  final s = raw.toString().trim();
  final parsed = int.tryParse(s);
  if (parsed != null) return parsed;
  switch (s.toLowerCase()) {
    case 'vacation':
      return 1;
    case 'emergency':
      return 2;
    case 'investment':
      return 3;
    default:
      return null;
  }
}

int? projectVisibilityToApiInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is double) return raw.toInt();
  final s = raw.toString().trim();
  final parsed = int.tryParse(s);
  if (parsed != null) return parsed;
  switch (s.toLowerCase()) {
    case 'public':
      return 1;
    case 'private':
      return 2;
    default:
      return null;
  }
}

int? projectStateToApiInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is int) return raw;
  if (raw is double) return raw.toInt();
  final s = raw.toString().trim();
  return int.tryParse(s);
}
