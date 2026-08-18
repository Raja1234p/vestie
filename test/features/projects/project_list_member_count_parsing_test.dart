import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/projects/data/models/project_list_json_parsing.dart';
import 'package:vestie/features/projects/data/models/project_summary_model.dart';

void main() {
  group('parseProjectListMemberCount', () {
    test('reads memberCount', () {
      expect(parseProjectListMemberCount({'memberCount': 5}), 5);
    });

    test('reads membersCount used by some list payloads', () {
      expect(parseProjectListMemberCount({'membersCount': 4}), 4);
    });

    test('reads numeric members field', () {
      expect(parseProjectListMemberCount({'members': 8}), 8);
    });

    test('counts members array', () {
      expect(
        parseProjectListMemberCount({
          'members': [
            {'id': 'a'},
            {'id': 'b'},
            {'id': 'c'},
          ],
        }),
        3,
      );
    });

    test('reads nested project.memberCount', () {
      expect(
        parseProjectListMemberCount({
          'id': 'p1',
          'project': {'memberCount': 6},
        }),
        6,
      );
    });

    test('reads currentMemberCount alias', () {
      expect(parseProjectListMemberCount({'currentMemberCount': 2}), 2);
    });

    test('missing or 0 stays 0 so vote copy is unchanged', () {
      expect(parseProjectListMemberCount({}), 0);
      expect(parseProjectListMemberCount({'memberCount': 0}), 0);
    });
  });

  group('ProjectSummaryModel list member count', () {
    test('maps membersCount onto eligibleMemberCount for voting, not cards', () {
      final model = ProjectSummaryModel.fromJson({
        'id': 'p1',
        'name': 'Trip',
        'description': '',
        'type': 'Vacation',
        'visibility': 'Public',
        'state': 'active',
        'targetAmount': 1000,
        'borrowingEnabled': false,
        'createdUtc': '2026-07-01T00:00:00Z',
        'membersCount': 5,
        'totalJoinedMember': 3,
      });
      expect(model.eligibleMemberCount, 5);
      expect(model.totalJoinedMember, 3);
    });
  });

  group('parseProjectListTotalJoinedMember', () {
    test('reads totalJoinedMember', () {
      expect(parseProjectListTotalJoinedMember({'totalJoinedMember': 4}), 4);
    });

    test('reads totalJoinedMembers alias', () {
      expect(parseProjectListTotalJoinedMember({'totalJoinedMembers': 6}), 6);
    });

    test('ignores voting memberCount', () {
      expect(
        parseProjectListTotalJoinedMember({
          'memberCount': 7,
          'totalJoinedMember': 2,
        }),
        2,
      );
      expect(
        parseProjectListTotalJoinedMember({'memberCount': 7}),
        0,
      );
    });

    test('null or missing stays 0 so UI can hide Total Members', () {
      expect(parseProjectListTotalJoinedMember({}), 0);
      expect(
        parseProjectListTotalJoinedMember({'totalJoinedMember': null}),
        0,
      );
    });
  });
}
