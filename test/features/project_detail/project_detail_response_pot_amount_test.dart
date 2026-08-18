import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
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

    test('parses totalContributed from project payload', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Test',
            'description': '',
            'type': 'investment',
            'visibility': 'public',
            'state': 'funded',
            'targetAmount': 5000,
            'totalContributed': 500,
            'raisedAmount': 0,
            'potAmount': 0,
            'endsAtUtc': null,
            'displayStatus': 'Funded',
          },
        ),
      ).toEntity();

      expect(entity.totalContributed, 500);
      expect(entity.currentAmount, 0);
      expect(entity.raisedDisplayAmount, 500);
    });

    test('vacation detail raisedDisplayAmount falls back to totalContributed', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Beach',
            'description': '',
            'type': 'vacation',
            'visibility': 'public',
            'state': 'active',
            'targetAmount': 5000,
            'totalContributed': 500,
            'raisedAmount': 0,
            'potAmount': 0,
            'endsAtUtc': null,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.raisedDisplayAmount, 500);
    });

    test('emergency detail raisedDisplayAmount falls back to totalContributed', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Rainy day',
            'description': '',
            'type': 'emergency',
            'visibility': 'public',
            'state': 'active',
            'targetAmount': 3000,
            'totalContributed': 750,
            'raisedAmount': 0,
            'potAmount': 0,
            'endsAtUtc': null,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.raisedDisplayAmount, 750);
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

    test('detail raisedDisplayAmount falls back to project viewerRefundAmount', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Trip',
            'description': '',
            'type': 'vacation',
            'visibility': 'public',
            'state': 'cancelled',
            'targetAmount': 5000,
            'raisedAmount': 0,
            'potAmount': 0,
            'totalContributed': 0,
            'viewerRefundAmount': 500,
            'endsAtUtc': null,
            'displayStatus': 'Cancelled',
          },
        ),
      ).toEntity();

      expect(entity.viewerRefundAmount, 500);
      expect(entity.raisedDisplayAmount, 500);
    });

    test('parses project.totalDistributedWithRoi from detail payload', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'inv1',
            'name': 'Fund',
            'description': '',
            'type': 'investment',
            'visibility': 'public',
            'state': 'funded',
            'targetAmount': 10000,
            'raisedAmount': 12000,
            'totalContributed': 10000,
            'viewerRefundAmount': 0,
            'totalDistributedWithRoi': 16500,
            'endsAtUtc': null,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.totalDistributedWithRoi, 16500);
    });

    test('detail prefers voting.viewerRefundAmount over project field', () {
      final entity = ProjectDetailResponseModel.fromJson({
        ..._minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Trip',
            'description': '',
            'type': 'vacation',
            'visibility': 'public',
            'state': 'cancelled',
            'targetAmount': 5000,
            'raisedAmount': 0,
            'potAmount': 0,
            'totalContributed': 0,
            'viewerRefundAmount': 100,
            'endsAtUtc': null,
            'displayStatus': 'Cancelled',
          },
        ),
        'votingStatus': 'done',
        'voting': {
          'startedAtUtc': '2026-07-01T12:00:00Z',
          'deadlineAtUtc': '2026-07-03T12:00:00Z',
          'agreedCount': 2,
          'disagreedCount': 3,
          'pendingCount': 0,
          'isFinalized': true,
          'voteType': 'StopContributionsVote',
          'outcome': 'Refund',
          'isApproved': false,
          'viewerRefundAmount': 500,
        },
      }).toEntity();

      expect(entity.effectiveViewerRefundAmount, 500);
      expect(entity.raisedDisplayAmount, 500);
      expect(entity.closureVoteOutcomeAmountUsd, 500);
    });
  });

  group('ProjectDetailResponseModel totalJoinedMember', () {
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
        'membersPagination': {
          'page': 1,
          'pageSize': 50,
          'totalCount': 9,
          'totalPages': 1,
        },
        'invites': [],
        'announcements': [],
      };
    }

    test('parses totalJoinedMember from project payload', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Test',
            'description': '',
            'type': 'vacation',
            'visibility': 'private',
            'state': 'active',
            'targetAmount': 500,
            'memberCount': null,
            'totalJoinedMember': 3,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.totalJoinedMember, 3);
      expect(entity.displayMemberCount, 3);
    });

    test('null totalJoinedMember stays 0 even when members[] and pagination exist', () {
      final entity = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          project: {
            'id': 'p1',
            'name': 'Test',
            'description': '',
            'type': 'vacation',
            'visibility': 'private',
            'state': 'active',
            'targetAmount': 500,
            'memberCount': null,
            'totalJoinedMember': null,
            'displayStatus': 'On Going',
          },
        ),
      ).toEntity();

      expect(entity.totalJoinedMember, 0);
      expect(entity.displayMemberCount, 0);
    });
  });
}
