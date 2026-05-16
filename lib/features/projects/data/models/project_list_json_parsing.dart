import '../../../../core/utils/safe_parser.dart';

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
      1 => 'Draft',
      2 => 'Active',
      3 => 'Completed',
      4 => 'Cancelled',
      _ => 'State$raw',
    };
  }
  final s = raw.toString().trim();
  if (s.isEmpty) return '';
  final asInt = int.tryParse(s);
  if (asInt != null) return projectStateApiValueToSummaryString(asInt);
  return s;
}

/// Prefers [displayStatus] from list payloads; falls back to [state] int/string.
String projectListStateLabel(Map<String, dynamic> json) {
  final display = json.safeString('displayStatus');
  if (display.isNotEmpty) return display;
  return projectStateApiValueToSummaryString(json['state']);
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

/// `GET /projects?scope=` — `viewerRole` on the project object (preferred).
String projectListItemViewerRole(Map<String, dynamic> json) {
  final onProject = json['viewerRole'];
  if (onProject != null && onProject.toString().trim().isNotEmpty) {
    return membershipRoleApiValueToString(onProject);
  }
  final viewerMembership = json['viewerMembership'];
  if (viewerMembership is Map) {
    final role = viewerMembership['role'];
    if (role != null && role.toString().trim().isNotEmpty) {
      return membershipRoleApiValueToString(role);
    }
  }
  return '';
}

/// `viewerMembership.role` / `members[].role` — int or string from API.
String membershipRoleApiValueToString(dynamic raw) {
  if (raw == null) return '';
  if (raw is int) {
    return switch (raw) {
      1 => 'GroupLeader',
      2 => 'CoLeader',
      3 => 'Member',
      _ => raw.toString(),
    };
  }
  final compact =
      raw.toString().trim().toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
  return switch (compact) {
    '1' || 'groupleader' || 'grouplead' || 'lead' || 'leader' => 'GroupLeader',
    '2' || 'coleader' => 'CoLeader',
    '3' || 'member' => 'Member',
    _ => raw.toString().trim(),
  };
}

/// `viewerMembership.status` / `members[].status` — int or string from API.
String membershipStatusApiValueToString(dynamic raw) {
  if (raw == null) return '';
  if (raw is int) {
    return switch (raw) {
      1 => 'Pending',
      2 => 'Active',
      3 => 'Inactive',
      _ => raw.toString(),
    };
  }
  return raw.toString().trim();
}
