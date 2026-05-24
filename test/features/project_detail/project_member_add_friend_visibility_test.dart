import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_member_add_friend_visibility.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

void main() {
  group('ProjectMemberAddFriendVisibility.showsVffBadge', () {
    const viewerMembershipId = 'viewer-m';
    const otherMembershipId = 'other-m';

    const project = ProjectDetailEntity(
      id: 'p1',
      name: 'Trip',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      goalAmount: 1000,
      currentAmount: 0,
      endsIn: '30d',
      announcement: '',
      members: [
        MemberEntity(
          id: 'viewer-user',
          membershipId: viewerMembershipId,
          userId: 'viewer-user',
          initials: 'ME',
          name: 'Me',
          role: MemberRole.member,
          contributedAmount: 0,
          vffConnectionState: VffConnectionState.connected,
        ),
        MemberEntity(
          id: 'other-user',
          membershipId: otherMembershipId,
          userId: 'other-user',
          initials: 'OT',
          name: 'Other',
          role: MemberRole.member,
          contributedAmount: 0,
          vffConnectionState: VffConnectionState.connected,
        ),
      ],
      borrowRequests: [],
      viewerRole: ViewerMembershipRole.member,
      membershipId: viewerMembershipId,
    );

    test('hides VFF badge on viewer own row', () {
      const self = MemberEntity(
        id: 'viewer-user',
        membershipId: viewerMembershipId,
        userId: 'viewer-user',
        initials: 'ME',
        name: 'Me',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
      );

      expect(
        ProjectMemberAddFriendVisibility.showsVffBadge(
          project: project,
          member: self,
        ),
        isFalse,
      );
    });

    test('shows VFF badge on other connected members', () {
      const other = MemberEntity(
        id: 'other-user',
        membershipId: otherMembershipId,
        userId: 'other-user',
        initials: 'OT',
        name: 'Other',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
      );

      expect(
        ProjectMemberAddFriendVisibility.showsVffBadge(
          project: project,
          member: other,
        ),
        isTrue,
      );
    });
  });
}
