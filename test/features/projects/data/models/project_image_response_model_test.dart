import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';
import 'package:vestie/features/projects/data/models/project_summary_model.dart';

void main() {
  const coverUrl =
      'https://vestiestorage.blob.core.windows.net/vestie-attachments/project-images/c6d6a11fc9aa4767a71d69dd94e07300/d578efb499bc402e83f0e847c002f3a0.jpg';

  const imagesJson = [
    {
      'id': '31605e1d-c400-49b7-9522-c41a351ae66f',
      'imageUrl': coverUrl,
      'sortOrder': 0,
    },
    {
      'id': '61d70b15-cdd7-419c-9445-4df9e1670ca8',
      'imageUrl':
          'https://vestiestorage.blob.core.windows.net/vestie-attachments/project-images/c6d6a11fc9aa4767a71d69dd94e07300/0ccae0238e6942c7b143d012338f5480.jpg',
      'sortOrder': 1,
    },
  ];

  group('ProjectSummaryModel project images', () {
    test('parses coverImageUrl and images from GET /projects item', () {
      final model = ProjectSummaryModel.fromJson({
        'id': 'p1',
        'name': 'Beach Trip',
        'description': 'Summer',
        'type': 'Vacation',
        'visibility': 'Public',
        'state': 'active',
        'targetAmount': 7000,
        'raisedAmount': 5000,
        'borrowingEnabled': true,
        'createdUtc': '2026-07-01T00:00:00Z',
        'coverImageUrl': coverUrl,
        'images': imagesJson,
      });

      expect(model.coverImageUrl, coverUrl);
      expect(model.images, hasLength(2));
      expect(model.images.first.id, '31605e1d-c400-49b7-9522-c41a351ae66f');
      expect(model.images.first.imageUrl, coverUrl);
      expect(model.images.first.sortOrder, 0);
      expect(model.images.last.sortOrder, 1);
    });

    test('defaults missing image fields to empty', () {
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
      });

      expect(model.coverImageUrl, isNull);
      expect(model.images, isEmpty);
    });
  });

  group('ProjectDetailResponseModel project images', () {
    test('parses coverImageUrl and images from nested project', () {
      final model = ProjectDetailResponseModel.fromJson({
        'project': {
          'id': 'p1',
          'name': 'Beach Trip',
          'description': 'Summer',
          'type': 'Vacation',
          'visibility': 'Public',
          'state': 'active',
          'targetAmount': 7000,
          'raisedAmount': 5000,
          'endsAtUtc': '2026-12-31T00:00:00Z',
          'viewerRole': 'GroupLeader',
          'borrowingEnabled': true,
          'createdUtc': '2026-07-01T00:00:00Z',
          'coverImageUrl': coverUrl,
          'images': imagesJson,
        },
        'rules': {},
        'viewerMembership': {
          'membershipId': 'm1',
          'userId': 'u1',
          'userName': 'leader',
          'firstName': 'L',
          'lastName': 'E',
          'role': 'leader',
          'status': 'active',
        },
        'members': [],
        'invites': [],
        'announcements': [],
      });

      expect(model.coverImageUrl, coverUrl);
      expect(model.images, hasLength(2));
      expect(model.images.first.sortOrder, 0);
    });
  });
}
