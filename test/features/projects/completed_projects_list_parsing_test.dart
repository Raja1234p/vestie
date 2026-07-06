import 'package:flutter_test/flutter_test.dart';

import 'package:vestie/core/models/pagination_dto.dart';
import 'package:vestie/features/projects/data/models/project_summary_model.dart';

void main() {
  group('GET /projects/completed parsing', () {
    test('parses completedProjects array and pagination', () {
      const json = {
        'completedProjects': [
          {
            'id': '6b5ef854-cd7a-42a8-b165-d95ad4ab6ba9',
            'name': 'gdchhcgx',
            'type': 'vacation',
            'status': 'completed',
            'targetAmount': 5000.0,
            'raisedAmount': 5000.0,
            'viewerRole': 'GroupLeader',
            'memberCount': 2,
            'completedAtUtc': '2026-07-06T18:20:03+00:00',
          },
        ],
        'pagination': {
          'page': 1,
          'pageSize': 20,
          'totalCount': 5,
          'totalPages': 1,
        },
      };

      final page = PaginatedListParser.parseKeyedList(
        json,
        'completedProjects',
        ProjectSummaryModel.fromJson,
      );

      expect(page.items, hasLength(1));
      expect(page.items.first.name, 'gdchhcgx');
      expect(page.items.first.state, 'completed');
      expect(page.items.first.viewerRole, 'GroupLeader');
      expect(page.items.first.maxMembers, 2);
      expect(page.items.first.endsAtUtc, isNotNull);
      expect(page.pagination.totalCount, 5);
    });
  });
}
