import '../../../../core/utils/roi_display_format.dart';
import '../../../../core/utils/safe_parser.dart';
import '../../../../user/features/vff/domain/entities/vff_enums.dart';

/// Maps API enum integers to the string labels used in [ProjectSummaryEntity]
/// and home [Project] mapping (see [ProjectsRepositoryImpl._mapCategory]).
/// True when API project type is Investment (int `3` or string label).
bool projectTypeIsInvestment(dynamic type) =>
    projectTypeApiValueToSummaryString(type).toLowerCase().contains('invest');

String? membershipPhotoUrlFromJson(Map<String, dynamic> json) {
  for (final key in const ['photoURL', 'photoUrl', 'profilePhotoUrl']) {
    final value = json.safeStringNullable(key);
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

bool membershipVffAddedFromJson(Map<String, dynamic> json) {
  final raw = json['VFFAdded'] ?? json['vffAdded'];
  if (raw is bool) return raw;
  if (raw is String) {
    return raw.trim().toLowerCase() == 'true';
  }
  return false;
}

/// Viewer-relative VFF on a project member — requires Connected + VFFAdded.
bool membershipViewerVffLinkedFromJson(
  Map<String, dynamic> json, {
  VffConnectionState? connectionState,
}) {
  final state = connectionState ?? membershipVffConnectionStateFromJson(json);
  if (state != VffConnectionState.connected) return false;
  return membershipVffAddedFromJson(json);
}

String? membershipPendingVffRequestId(Map<String, dynamic> json) {
  final raw = json.safeStringNullable('pendingVffRequestId');
  if (raw == null || raw.trim().isEmpty) return null;
  return raw.trim();
}

/// Resolves VFF connection state from membership JSON; pending request id implies outgoing.
VffConnectionState membershipVffConnectionStateFromJson(
  Map<String, dynamic> json, {
  List<String> nestedKeys = const [
    'membership',
    'member',
    'viewerMembership',
    'profile',
  ],
}) {
  final root = VffConnectionState.parse(
    json.safeStringNullable('vffConnectionState'),
  );
  if (root != VffConnectionState.none) return root;

  for (final key in nestedKeys) {
    final nested = json[key];
    if (nested is! Map<String, dynamic>) continue;
    final fromNested = VffConnectionState.parse(
      nested.safeStringNullable('vffConnectionState'),
    );
    if (fromNested != VffConnectionState.none) return fromNested;
  }

  if (membershipPendingVffRequestId(json) != null) {
    return VffConnectionState.pendingOutgoing;
  }
  for (final key in nestedKeys) {
    final nested = json[key];
    if (nested is! Map<String, dynamic>) continue;
    if (membershipPendingVffRequestId(nested) != null) {
      return VffConnectionState.pendingOutgoing;
    }
  }
  return VffConnectionState.none;
}

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
  if (raw is double)
    return projectVisibilityApiValueToSummaryString(raw.toInt());
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

/// Prefers [displayStatus] from list payloads; falls back to [status] or [state].
String projectListStateLabel(Map<String, dynamic> json) {
  final display = json.safeString('displayStatus');
  if (display.isNotEmpty) return display;
  final status = json.safeString('status');
  if (status.isNotEmpty) return status;
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

/// Investment ROI from list/detail payloads (`roiPercentage` or `roi`).
double? parseApiRoiPercent(Map<String, dynamic> json) {
  final roiPercentage = json.safeDoubleNullable('roiPercentage');
  final roi = json.safeDoubleNullable('roi');
  return normalizeDisplayableRoi(roiPercentage ?? roi);
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
  final compact = raw.toString().trim().toLowerCase().replaceAll(
    RegExp(r'[\s_-]'),
    '',
  );
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

/// Eligible-voter count from `GET /projects` list rows (`memberCount` etc.).
/// Used for vote-outcome copy — not Home **Total Members**.
int parseProjectListMemberCount(Map<String, dynamic> json) {
  int fromMap(Map<String, dynamic> map) {
    const keys = [
      'memberCount',
      'membersCount',
      'currentMemberCount',
      'activeMemberCount',
      'totalMembers',
      'totalMemberCount',
      'MemberCount',
      'MembersCount',
      'CurrentMemberCount',
    ];
    for (final key in keys) {
      if (map[key] == null) continue;
      final n = map.safeInt(key);
      if (n > 0) return n;
    }

    final members = map['members'] ?? map['Members'];
    if (members is num) {
      final n = members.toInt();
      if (n > 0) return n;
    }
    if (members is String) {
      final n = int.tryParse(members.trim()) ?? 0;
      if (n > 0) return n;
    }
    if (members is List && members.isNotEmpty) {
      return members.length;
    }
    if (members is Map) {
      final nested = Map<String, dynamic>.from(members);
      final total = nested.safeInt('totalCount');
      if (total > 0) return total;
      final pagination = nested['pagination'];
      if (pagination is Map) {
        final page = Map<String, dynamic>.from(pagination);
        final paged = page.safeInt('totalCount');
        if (paged > 0) return paged;
      }
    }
    return 0;
  }

  var count = fromMap(json);
  if (count > 0) return count;

  for (final key in const ['project', 'stats', 'summary']) {
    final nested = json[key];
    if (nested is! Map) continue;
    count = fromMap(Map<String, dynamic>.from(nested));
    if (count > 0) return count;
  }
  return 0;
}

/// Roster size for Home/Discover/completed/detail **Total Members**.
///
/// Contract: `totalJoinedMember` (not `memberCount`, which is eligible
/// voters). Missing or 0 is stored as 0; UI hides the Total Members row.
int parseProjectListTotalJoinedMember(Map<String, dynamic> json) {
  int fromMap(Map<String, dynamic> map) {
    const keys = [
      'totalJoinedMember',
      'totalJoinedMembers',
      'TotalJoinedMember',
      'TotalJoinedMembers',
    ];
    for (final key in keys) {
      if (map[key] == null) continue;
      final n = map.safeInt(key);
      if (n > 0) return n;
    }
    return 0;
  }

  var count = fromMap(json);
  if (count > 0) return count;

  for (final key in const ['project', 'stats', 'summary']) {
    final nested = json[key];
    if (nested is! Map) continue;
    count = fromMap(Map<String, dynamic>.from(nested));
    if (count > 0) return count;
  }
  return 0;
}
