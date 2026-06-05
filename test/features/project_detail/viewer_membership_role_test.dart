import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';

void main() {
  group('ViewerMembershipRole.forProjectDetail', () {
    test('prefers CoLeader from membership when project viewerRole is Member', () {
      expect(
        ViewerMembershipRole.forProjectDetail(
          projectViewerRole: 'Member',
          membershipRole: 'CoLeader',
        ),
        ViewerMembershipRole.coLeader,
      );
    });

    test('prefers GroupLeader when project says leader and membership says member', () {
      expect(
        ViewerMembershipRole.forProjectDetail(
          projectViewerRole: 'GroupLeader',
          membershipRole: 'Member',
        ),
        ViewerMembershipRole.groupLeader,
      );
    });

    test('falls back to membership when project viewerRole is empty', () {
      expect(
        ViewerMembershipRole.forProjectDetail(
          projectViewerRole: '',
          membershipRole: 'CoLeader',
        ),
        ViewerMembershipRole.coLeader,
      );
    });

    test('defaults to member when both roles are empty', () {
      expect(
        ViewerMembershipRole.forProjectDetail(
          projectViewerRole: '',
          membershipRole: '',
        ),
        ViewerMembershipRole.member,
      );
    });
  });
}
