import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';

void main() {
  group('ViewerMembershipRole.forProjectDetail', () {
    test(
      'prefers CoLeader from membership when project viewerRole is Member',
      () {
        expect(
          ViewerMembershipRole.forProjectDetail(
            projectViewerRole: 'Member',
            membershipRole: 'CoLeader',
          ),
          ViewerMembershipRole.coLeader,
        );
      },
    );

    test(
      'prefers GroupLeader when project says leader and membership says member',
      () {
        expect(
          ViewerMembershipRole.forProjectDetail(
            projectViewerRole: 'GroupLeader',
            membershipRole: 'Member',
          ),
          ViewerMembershipRole.groupLeader,
        );
      },
    );

    test('falls back to membership when project viewerRole is empty', () {
      expect(
        ViewerMembershipRole.forProjectDetail(
          projectViewerRole: '',
          membershipRole: 'CoLeader',
        ),
        ViewerMembershipRole.coLeader,
      );
    });

    test('prefers co-leader row in members when viewerMembership says member', () {
      const viewerMembershipId = 'co-m';
      expect(
        ViewerMembershipRole.forProjectDetail(
          projectViewerRole: 'Member',
          membershipRole: 'member',
          viewerMembershipId: viewerMembershipId,
          members: [
            MemberEntity(
              id: 'co-u',
              membershipId: viewerMembershipId,
              userId: 'co-u',
              initials: 'CL',
              name: 'Co',
              role: MemberRole.coLeader,
              contributedAmount: 0,
            ),
          ],
        ),
        ViewerMembershipRole.coLeader,
      );
    });

    test('resolves co-leader from viewer userId when membership id mismatches', () {
      expect(
        ViewerMembershipRole.forProjectDetail(
          projectViewerRole: 'Member',
          membershipRole: 'member',
          viewerUserId: 'co-u',
          members: [
            MemberEntity(
              id: 'co-u',
              membershipId: 'different-m',
              userId: 'co-u',
              initials: 'CL',
              name: 'Co',
              role: MemberRole.coLeader,
              contributedAmount: 0,
            ),
          ],
        ),
        ViewerMembershipRole.coLeader,
      );
    });
  });
}
