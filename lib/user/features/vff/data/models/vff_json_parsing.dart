import 'package:vestie/core/utils/safe_parser.dart';

import '../../domain/entities/vff_enums.dart';
import '../../domain/entities/vff_profile_entity.dart';

abstract final class VffJsonParsing {
  /// `GET /users/me/vffs` — raw array or `{ data: [...] }`.
  static List<Map<String, dynamic>> parseObjectList(dynamic raw) {
    var data = raw;
    if (data is Map) {
      final map = data.cast<String, dynamic>();
      for (final key in const [
        'data',
        'items',
        'value',
        'results',
        'connections',
      ]) {
        final nested = map[key];
        if (nested is List) {
          data = nested;
          break;
        }
      }
    }
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .toList(growable: false);
  }

  static String normalizeUserId(String id) => id.trim().toLowerCase();

  static DateTime? parseUtc(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  static String readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json.safeStringNullable(key);
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  static VffProfileStatsEntity mapStats(Map<String, dynamic> json) {
    if (json.isEmpty) return const VffProfileStatsEntity();
    return VffProfileStatsEntity(
      joinedProjectsCount: json.safeInt('joinedProjectsCount'),
      contributionCount: json.safeInt('contributionCount'),
      totalContributedAmount: json.safeDouble('totalContributedAmount'),
    );
  }

  static VffJoinedProjectEntity mapJoinedProject(Map<String, dynamic> json) {
    final joinRaw = readString(json, const ['joinState', 'viewerJoinState']);
    return VffJoinedProjectEntity(
      projectId: readString(json, const ['projectId']),
      name: readString(json, const ['name', 'projectName']),
      type: json.safeStringNullable('type'),
      visibility: VffProjectVisibility.parse(
        json.safeStringNullable('visibility'),
      ),
      state: json.safeStringNullable('state'),
      joinState: VffProjectJoinState.parse(joinRaw),
      memberCount: json.safeInt('memberCount'),
    );
  }
}
