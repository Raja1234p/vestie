import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/data/models/project_detail_response_model.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';

void main() {
  group('ProjectDetailResponseModel member overdueAmount', () {
    Map<String, dynamic> _minimalProjectJson({
      required List<Map<String, dynamic>> members,
    }) {
      return {
        'project': {
          'id': 'p1',
          'name': 'Test Project',
          'description': '',
          'type': 'investment',
          'visibility': 'private',
          'lifecycleState': 'active',
          'targetAmount': 1000,
          'raisedAmount': 500,
          'endsAtUtc': '2026-12-31T00:00:00Z',
        },
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
        'members': members,
        'invites': [],
        'announcements': [],
      };
    }

    test('parses overdueAmount when badge is Overdue', () {
      final model = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          members: [
            {
              'membershipId': 'm1',
              'userId': 'u1',
              'userName': 'alice',
              'firstName': 'Alice',
              'lastName': 'Lien',
              'role': 'member',
              'status': 'active',
              'badge': 'Overdue',
              'overdueAmount': 200,
            },
          ],
        ),
      );

      final entity = model.toEntity();
      final member = entity.members.single;

      expect(member.badge, MemberEntity.overdueBadgeLabel);
      expect(member.overdueAmount, 200);
      expect(member.showsOverdueBadge, isTrue);
      expect(member.showsContributionBadge, isFalse);
    });

    test('Top Contributor badge does not show overdue pill', () {
      final member = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          members: [
            {
              'membershipId': 'm1',
              'userId': 'u1',
              'userName': 'alice',
              'firstName': 'Alice',
              'lastName': 'Lien',
              'role': 'member',
              'status': 'active',
              'badge': 'Top Contributor',
              'overdueAmount': 200,
            },
          ],
        ),
      ).toEntity().members.single;

      expect(member.showsContributionBadge, isTrue);
      expect(member.showsOverdueBadge, isFalse);
    });

    test('falls back to totalOverdue and overdueBorrowAmount keys', () {
      final fromTotal = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          members: [
            {
              'membershipId': 'm1',
              'userId': 'u1',
              'userName': 'bob',
              'firstName': 'Bob',
              'lastName': 'Lee',
              'role': 'member',
              'status': 'active',
              'badge': 'Overdue',
              'totalOverdue': 75,
            },
          ],
        ),
      ).toEntity().members.single;

      final fromBorrow = ProjectDetailResponseModel.fromJson(
        _minimalProjectJson(
          members: [
            {
              'membershipId': 'm2',
              'userId': 'u2',
              'userName': 'carol',
              'firstName': 'Carol',
              'lastName': 'Kim',
              'role': 'member',
              'status': 'active',
              'badge': 'Overdue',
              'overdueBorrowAmount': 50,
            },
          ],
        ),
      ).toEntity().members.single;

      expect(fromTotal.overdueAmount, 75);
      expect(fromTotal.showsOverdueBadge, isTrue);
      expect(fromBorrow.overdueAmount, 50);
      expect(fromBorrow.showsOverdueBadge, isTrue);
    });
  });
}
