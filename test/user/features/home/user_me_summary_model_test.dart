import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/home/data/models/user_me_summary_model.dart';

void main() {
  group('UserMeSummaryModel.fromJson', () {
    test('parses API summary response', () {
      final entity = UserMeSummaryModel.fromJson({
        'totalContributedAllTime': 4223.5,
        'activeProjectsCount': 4,
        'completedProjectsCount': 0,
        'joinedProjectsCount': 35,
      }).toEntity();

      expect(entity.totalContributed, 4223.5);
      expect(entity.activeProjectsCount, 4);
      expect(entity.completedProjectsCount, 0);
      expect(entity.joinedProjectsCount, 35);
    });

    test('parses nested data envelope', () {
      final entity = UserMeSummaryModel.fromJson({
        'data': {
          'totalContributedAllTime': 0.0,
          'activeProjectsCount': 1,
          'completedProjectsCount': 2,
          'joinedProjectsCount': 3,
        },
      }).toEntity();

      expect(entity.totalContributed, 0);
      expect(entity.activeProjectsCount, 1);
      expect(entity.completedProjectsCount, 2);
      expect(entity.joinedProjectsCount, 3);
    });
  });
}
