import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/widgets/member_detail_actions_visibility.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

void main() {
  group('MemberDetailActionsVisibility.showVffSendOrSent', () {
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
          canSendVffRequest: false,
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
          canSendVffRequest: false,
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
