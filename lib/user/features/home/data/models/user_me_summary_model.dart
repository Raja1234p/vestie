import 'package:vestie/core/utils/safe_parser.dart';

import '../../domain/entities/user_me_summary_entity.dart';

class UserMeSummaryModel {
  final UserMeSummaryEntity entity;

  const UserMeSummaryModel(this.entity);

  factory UserMeSummaryModel.fromJson(Map<String, dynamic> json) {
    final root = _rootMap(json);
    return UserMeSummaryModel(
      UserMeSummaryEntity(
        totalContributed: root.safeDouble('totalContributedAllTime'),
        activeProjectsCount: root.safeInt('activeProjectsCount'),
        completedProjectsCount: root.safeInt('completedProjectsCount'),
        joinedProjectsCount: root.safeInt('joinedProjectsCount'),
      ),
    );
  }

  UserMeSummaryEntity toEntity() => entity;

  static Map<String, dynamic> _rootMap(Map<String, dynamic> json) {
    for (final key in const ['data', 'summary', 'result']) {
      final nested = json[key];
      if (nested is Map) {
        return nested.cast<String, dynamic>();
      }
    }
    return json;
  }
}
