import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';

void main() {
  group('ProjectDetailResponseModel project potAmount', () {
    Map<String, dynamic> _minimalProjectJson({
      required Map<String, dynamic> project,
    }) {
      return {
        'project': project,
        'rules': {},
        'viewerMembership': {
          'membershipId': 'vm1',
          'userId': 'viewer',
          'userName': 'viewer',
          'firstName': 'View',
          'lastName': 'Er',
          'role': 'member',
          'status': 'active',
          'badge': '',
        },
        'members': [],
        'invites': [],
        'announcements': [],
      };
    }

    test('uses potAmount instead of raisedAmount when potAmount is present', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Test',
            'description': '',
            'type': 'vacation',
            'visibility': 'public',
            'state': 'active',
            'targetAmount': 5000,
            'raisedAmount': 10,
            'potAmount': 0,
            'endsAtUtc': null,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.currentAmount, 0);
    });

    test('falls back to raisedAmount when potAmount is omitted', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Test',
            'description': '',
            'type': 'vacation',
            'visibility': 'public',
            'state': 'active',
            'targetAmount': 5000,
            'raisedAmount': 10,
            'endsAtUtc': null,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.currentAmount, 10);
    });

    test('uses positive potAmount when provided', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Test',
            'description': '',
            'type': 'vacation',
            'visibility': 'public',
            'state': 'active',
            'targetAmount': 5000,
            'raisedAmount': 10,
            'potAmount': 250,
            'endsAtUtc': null,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.currentAmount, 250);
    });
  });
}
