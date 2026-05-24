import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_connection_entity.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';
import 'package:vestie/user/features/vff/presentation/mappers/invite_members_mapper.dart';

void main() {
  const vffUserId = '631d4543-07c1-4ffc-8613-401bfd9589ea';

  const connection = VffConnectionEntity(
    userId: vffUserId,
    fullName: 'ai studio',
    mutualProjectsCount: 11,
  );

  group('InviteMembersMapper.fromConnections', () {
    test('includes connected VFF when not in project members', () {
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
            id: 'viewer',
            membershipId: 'm-viewer',
            userId: 'viewer',
            initials: 'ME',
            name: 'Me',
            role: MemberRole.leader,
            contributedAmount: 0,
          ),
        ],
        borrowRequests: [],
        viewerRole: ViewerMembershipRole.groupLeader,
        membershipId: 'm-viewer',
      );

      final rows = InviteMembersMapper.fromConnections(
        const [connection],
        excludeUserIds: InviteMembersMapper.excludeUserIdsForProject(project),
      );

      expect(rows, hasLength(1));
      expect(rows.first.id, vffUserId);
    });

    test('excludes connected VFF already in project members', () {
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
            id: 'viewer',
            membershipId: 'm-viewer',
            userId: 'viewer',
            initials: 'ME',
            name: 'Me',
            role: MemberRole.leader,
            contributedAmount: 0,
          ),
          MemberEntity(
            id: vffUserId,
            membershipId: 'm-vff',
            userId: vffUserId,
            initials: 'AS',
            name: 'ai studio',
            role: MemberRole.member,
            contributedAmount: 0,
          ),
        ],
        borrowRequests: [],
        viewerRole: ViewerMembershipRole.groupLeader,
        membershipId: 'm-viewer',
      );

      final rows = InviteMembersMapper.fromConnections(
        const [connection],
        excludeUserIds: InviteMembersMapper.excludeUserIdsForProject(project),
      );

      expect(rows, isEmpty);
    });

    test('excludes pending outgoing VFF requests', () {
      const pending = VffConnectionEntity(
        userId: 'other',
        fullName: 'Pat',
        outgoingRequestStatus: VffOutgoingRequestStatus.requestSent,
      );

      final rows = InviteMembersMapper.fromConnections(const [pending]);

      expect(rows, isEmpty);
    });
  });
}
