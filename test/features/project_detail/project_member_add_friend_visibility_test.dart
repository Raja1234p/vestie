import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_add_friend_visibility.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

void main() {
  group('ProjectMemberAddFriendVisibility.shouldShow', () {
    const viewerMembershipId = 'viewer-m';
    const otherMembershipId = 'other-m';

    ProjectDetailEntity projectFor(ViewerMembershipRole viewerRole) {
      return ProjectDetailEntity(
        id: 'p1',
        name: 'Project',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: [
          const MemberEntity(
            id: 'viewer-user',
            membershipId: viewerMembershipId,
            userId: 'viewer-user',
            initials: 'ME',
            name: 'Me',
            role: MemberRole.member,
            contributedAmount: 0,
          ),
        ],
        borrowRequests: [],
        viewerRole: viewerRole,
        membershipId: viewerMembershipId,
      );
    }

    const otherMember = MemberEntity(
      id: 'other-user',
      membershipId: otherMembershipId,
      userId: 'other-user',
      initials: 'OT',
      name: 'Other',
      role: MemberRole.coLeader,
      contributedAmount: 0,
      vffConnectionState: VffConnectionState.none,
    );

    const self = MemberEntity(
      id: 'viewer-user',
      membershipId: viewerMembershipId,
      userId: 'viewer-user',
      initials: 'ME',
      name: 'Me',
      role: MemberRole.member,
      contributedAmount: 0,
      vffConnectionState: VffConnectionState.none,
    );

    test('hides Send VFF on viewer own row only', () {
      final project = projectFor(ViewerMembershipRole.groupLeader);

      expect(
        ProjectMemberAddFriendVisibility.shouldShow(
          project: project,
          member: self,
        ),
        isFalse,
      );
      expect(
        ProjectMemberAddFriendVisibility.shouldShow(
          project: project,
          member: otherMember,
        ),
        isTrue,
      );
    });

    test('member viewer can send VFF to another member (any role)', () {
      const peer = MemberEntity(
        id: 'peer-user',
        membershipId: 'peer-m',
        userId: 'peer-user',
        initials: 'PE',
        name: 'Peer',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.none,
      );

      expect(
        ProjectMemberAddFriendVisibility.shouldShow(
          project: projectFor(ViewerMembershipRole.member),
          member: peer,
        ),
        isTrue,
      );
    });

    test('same rules for group leader, co-leader, and member viewers', () {
      for (final role in ViewerMembershipRole.values) {
        expect(
          ProjectMemberAddFriendVisibility.shouldShow(
            project: projectFor(role),
            member: otherMember,
          ),
          isTrue,
          reason: '${role.apiLabel}',
        );
      }
    });

    test('same rules for emergency and investment categories', () {
      for (final category in [
        ProjectCategory.emergency,
        ProjectCategory.investment,
      ]) {
        final project = ProjectDetailEntity(
          id: 'p-$category',
          name: 'Project',
          category: category,
          status: ProjectStatus.ongoing,
          goalAmount: 1000,
          currentAmount: 0,
          endsIn: '30d',
          announcement: '',
          members: [],
          borrowRequests: [],
          viewerRole: ViewerMembershipRole.member,
          membershipId: viewerMembershipId,
        );
        expect(
          ProjectMemberAddFriendVisibility.shouldShow(
            project: project,
            member: otherMember,
          ),
          isTrue,
          reason: '$category',
        );
      }
    });
  });
}
