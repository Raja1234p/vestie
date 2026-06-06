import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/widgets/member_detail_actions_visibility.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

ProjectDetailEntity _moderatorProject({
  required ProjectCategory category,
  required ViewerMembershipRole viewerRole,
  List<MemberEntity> members = const [],
  String membershipId = 'viewer-m',
}) {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Test',
    category: category,
    status: ProjectStatus.ongoing,
    goalAmount: 1000,
    currentAmount: 0,
    endsIn: '30d',
    announcement: '',
    members: members,
    borrowRequests: [],
    viewerRole: viewerRole,
    membershipId: membershipId,
  );
}

void main() {
  group('MemberDetailActionsVisibility.showRemoveMember', () {
    test(
      'true for group leader or co-leader viewing a regular member on every category',
      () {
        const member = MemberEntity(
          id: 'u2',
          membershipId: 'm2',
          userId: 'u2',
          initials: 'AB',
          name: 'Alex',
          role: MemberRole.member,
          contributedAmount: 0,
        );

        for (final category in ProjectCategory.values) {
          for (final role in [
            ViewerMembershipRole.groupLeader,
            ViewerMembershipRole.coLeader,
          ]) {
            expect(
              MemberDetailActionsVisibility.showRemoveMember(
                project: _moderatorProject(
                  category: category,
                  viewerRole: role,
                  membershipId: role == ViewerMembershipRole.coLeader
                      ? 'co-m'
                      : 'leader-m',
                ),
                member: member,
              ),
              isTrue,
              reason: 'remove should show for $category as $role',
            );
          }
        }
      },
    );

    test('false for regular member viewer', () {
      const project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: [],
        borrowRequests: [],
        viewerRole: ViewerMembershipRole.member,
        membershipId: 'member-m',
      );
      const target = MemberEntity(
        id: 'u2',
        membershipId: 'm2',
        userId: 'u2',
        initials: 'AB',
        name: 'Alex',
        role: MemberRole.member,
        contributedAmount: 0,
      );

      expect(
        MemberDetailActionsVisibility.showRemoveMember(
          project: project,
          member: target,
        ),
        isFalse,
      );
    });

    test('false for self and for project leader row', () {
      const leaderMember = MemberEntity(
        id: 'gl',
        membershipId: 'leader-m',
        userId: 'gl',
        initials: 'GL',
        name: 'Leader',
        role: MemberRole.leader,
        contributedAmount: 0,
      );
      final project = _moderatorProject(
        category: ProjectCategory.investment,
        viewerRole: ViewerMembershipRole.groupLeader,
        members: [leaderMember],
        membershipId: 'leader-m',
      );

      expect(
        MemberDetailActionsVisibility.showRemoveMember(
          project: project,
          member: leaderMember,
        ),
        isFalse,
      );
      expect(
        MemberDetailActionsVisibility.showRemoveMember(
          project: project,
          member: leaderMember.copyWith(role: MemberRole.member),
        ),
        isFalse,
        reason:
            'leader slot in members list blocks remove even if role field is member',
      );
    });

    test(
      'true when activity role is leader but member is not leader in project list',
      () {
        const listMember = MemberEntity(
          id: 'u2',
          membershipId: 'm2',
          userId: 'u2',
          initials: 'AB',
          name: 'Alex',
          role: MemberRole.member,
          contributedAmount: 0,
        );
        final misTagged = listMember.copyWith(role: MemberRole.leader);
        final project = _moderatorProject(
          category: ProjectCategory.emergency,
          viewerRole: ViewerMembershipRole.coLeader,
          members: [listMember],
          membershipId: 'co-m',
        );

        expect(
          MemberDetailActionsVisibility.showRemoveMember(
            project: project,
            member: misTagged,
          ),
          isTrue,
        );
      },
    );
  });

  group('MemberDetailActionsVisibility.isVffActionTarget', () {
    test('false for self, true for any other member regardless of roles', () {
      const viewerMembershipId = 'viewer-m';
      const project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.emergency,
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

      const self = MemberEntity(
        id: 'viewer',
        membershipId: viewerMembershipId,
        userId: 'viewer',
        initials: 'ME',
        name: 'Me',
        role: MemberRole.member,
        contributedAmount: 0,
      );

      const groupLeader = MemberEntity(
        id: 'gl',
        membershipId: 'gl-m',
        userId: 'gl',
        initials: 'GL',
        name: 'Leader',
        role: MemberRole.leader,
        contributedAmount: 0,
      );

      expect(
        MemberDetailActionsVisibility.isVffActionTarget(
          project: project,
          member: self,
        ),
        isFalse,
      );
      expect(
        MemberDetailActionsVisibility.isVffActionTarget(
          project: project,
          member: groupLeader,
        ),
        isTrue,
      );
    });
  });

  group('MemberDetailActionsVisibility.showVffSendOrSent', () {
    test(
      'shows Send VFF when canSendVffRequest is false but state is none',
      () {
        const project = ProjectDetailEntity(
          id: 'p1',
          name: 'Vacation',
          category: ProjectCategory.vacations,
          status: ProjectStatus.ongoing,
          goalAmount: 1000,
          currentAmount: 0,
          endsIn: '30d',
          announcement: '',
          members: [],
          borrowRequests: [],
          viewerRole: ViewerMembershipRole.groupLeader,
          membershipId: 'viewer-membership',
        );

        const member = MemberEntity(
          id: 'user-2',
          membershipId: 'm2',
          userId: 'user-2',
          initials: 'AB',
          name: 'Alex',
          role: MemberRole.member,
          contributedAmount: 0,
          vffConnectionState: VffConnectionState.none,
          canSendVffRequest: false,
        );

        expect(
          MemberDetailActionsVisibility.showVffSendOrSent(
            project: project,
            member: member,
            vffConnectionState: VffConnectionState.none,
          ),
          isTrue,
        );
      },
    );

    test('shows Request Sent when activity reports PendingOutgoing', () {
      const project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: [],
        borrowRequests: [],
        viewerRole: ViewerMembershipRole.groupLeader,
        membershipId: 'viewer-membership',
      );

      const member = MemberEntity(
        id: 'user-2',
        membershipId: 'm2',
        userId: 'user-2',
        initials: 'AB',
        name: 'Alex',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.pendingOutgoing,
        canSendVffRequest: false,
      );

      expect(
        MemberDetailActionsVisibility.showVffSendOrSent(
          project: project,
          member: member,
          vffConnectionState: VffConnectionState.pendingOutgoing,
        ),
        isTrue,
      );
    });
  });

  group('MemberDetailActionsVisibility.showVffFollowing', () {
    test('shows Following when vffConnectionState is Connected', () {
      const project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: [],
        borrowRequests: [],
        viewerRole: ViewerMembershipRole.groupLeader,
        membershipId: 'viewer-membership',
      );

      const member = MemberEntity(
        id: 'user-2',
        membershipId: 'm2',
        userId: 'user-2',
        initials: 'AB',
        name: 'Alex',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
      );

      expect(
        MemberDetailActionsVisibility.showVffFollowing(
          project: project,
          member: member,
          vffConnectionState: VffConnectionState.connected,
        ),
        isTrue,
      );
      expect(
        MemberDetailActionsVisibility.showVffSendOrSent(
          project: project,
          member: member,
          vffConnectionState: VffConnectionState.connected,
        ),
        isFalse,
      );
    });

    test('shows Following when project list member is Connected', () {
      const project = ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: [],
        borrowRequests: [],
        viewerRole: ViewerMembershipRole.groupLeader,
        membershipId: 'viewer-membership',
      );

      const member = MemberEntity(
        id: 'user-2',
        membershipId: 'm2',
        userId: 'user-2',
        initials: 'AB',
        name: 'Alex',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
      );

      expect(
        MemberDetailActionsVisibility.showVffFollowing(
          project: project,
          member: member,
          vffConnectionState: VffConnectionState.none,
        ),
        isTrue,
      );
    });
  });
}
