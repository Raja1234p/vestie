import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

MemberEntity _member({
  VffConnectionState vffConnectionState = VffConnectionState.none,
  bool vffAdded = false,
  String id = 'u1',
  String? pendingVffRequestId,
}) {
  return MemberEntity(
    id: id,
    membershipId: 'm1',
    userId: id,
    initials: 'AB',
    name: 'Alex',
    role: MemberRole.member,
    contributedAmount: 0,
    vffConnectionState: vffConnectionState,
    vffAdded: vffAdded,
    pendingVffRequestId: pendingVffRequestId,
  );
}

void main() {
  group('MemberEntity.mergedWithActivity VFF state', () {
    test(
      'uses API disconnected state after VFF remove (ignores stale route seed)',
      () {
        final seed = _member(
          vffConnectionState: VffConnectionState.connected,
          vffAdded: true,
        );
        final fromApi = _member(
          vffConnectionState: VffConnectionState.none,
          vffAdded: false,
        );

        final merged = seed.mergedWithActivity(fromApi);

        expect(merged.vffConnectionState, VffConnectionState.none);
        expect(merged.isVffConnected, isFalse);
        expect(merged.vffAdded, isFalse);
      },
    );

    test(
      'keeps route pending outgoing when activity API has not caught up',
      () {
        final seed = _member(
          vffConnectionState: VffConnectionState.pendingOutgoing,
        );
        final fromApi = _member(vffConnectionState: VffConnectionState.none);

        final merged = seed.mergedWithActivity(fromApi);

        expect(merged.vffConnectionState, VffConnectionState.pendingOutgoing);
      },
    );

    test('uses API connected state when available', () {
      final seed = _member(vffConnectionState: VffConnectionState.none);
      final fromApi = _member(
        vffConnectionState: VffConnectionState.connected,
        vffAdded: true,
      );

      final merged = seed.mergedWithActivity(fromApi);

      expect(merged.vffConnectionState, VffConnectionState.connected);
      expect(merged.vffAdded, isTrue);
    });

    test('normalizes pending request id to pending outgoing after reload', () {
      final seed = _member();
      final fromApi = _member(pendingVffRequestId: 'req-42');

      final merged = seed.mergedWithActivity(fromApi);

      expect(merged.hasPendingVffOutgoing, isTrue);
      expect(merged.vffConnectionState, VffConnectionState.pendingOutgoing);
      expect(merged.pendingVffRequestId, 'req-42');
    });
  });

  group('MemberEntity.hasPendingVffOutgoing', () {
    test('is true when pendingVffRequestId is set without enum state', () {
      final member = _member(pendingVffRequestId: 'req-1');

      expect(member.hasPendingVffOutgoing, isTrue);
    });

    test('is false when connected even if pending id is stale', () {
      final member = _member(
        vffConnectionState: VffConnectionState.connected,
        pendingVffRequestId: 'req-1',
        vffAdded: true,
      );

      expect(member.hasPendingVffOutgoing, isFalse);
    });
  });

  group('MemberEntity.showsContributionBadge', () {
    test('shows Top Contributor on member, leader, and co-leader rows', () {
      const badge = 'Top Contributor';
      const roles = [
        MemberRole.member,
        MemberRole.leader,
        MemberRole.coLeader,
      ];

      for (final role in roles) {
        final member = MemberEntity(
          id: 'u-$role',
          initials: 'TC',
          name: 'Taylor',
          role: role,
          contributedAmount: 0,
          badge: badge,
        );
        expect(
          member.showsContributionBadge,
          isTrue,
          reason: 'Top Contributor should show for $role',
        );
      }
    });

    test('hides Leader, Contributor, and other badge labels', () {
      const base = MemberEntity(
        id: 'u2',
        initials: 'MB',
        name: 'Member',
        role: MemberRole.member,
        contributedAmount: 0,
        badge: '',
      );

      for (final label in [
        'Leader',
        'Group Leader',
        'Co Leader',
        'Contributor',
        'groupLead',
      ]) {
        expect(
          base.copyWith(badge: label).showsContributionBadge,
          isFalse,
          reason: '$label should not show',
        );
      }
    });

    test('memberBadgeFromApi keeps only Top Contributor and Overdue', () {
      expect(
        MemberEntity.memberBadgeFromApi('Top Contributor'),
        MemberEntity.topContributorBadgeLabel,
      );
      expect(MemberEntity.memberBadgeFromApi('top_contributor'),
          MemberEntity.topContributorBadgeLabel);
      expect(
        MemberEntity.memberBadgeFromApi('Overdue'),
        MemberEntity.overdueBadgeLabel,
      );
      expect(MemberEntity.memberBadgeFromApi('overdue'),
          MemberEntity.overdueBadgeLabel);
      expect(MemberEntity.memberBadgeFromApi('Contributor'), '');
      expect(MemberEntity.memberBadgeFromApi('Leader'), '');
    });
  });

  group('MemberEntity.showsOverdueBadge', () {
    test('shows when badge is Overdue and overdueAmount is greater than zero', () {
      final member = MemberEntity(
        id: 'u-overdue',
        initials: 'OD',
        name: 'Overdue User',
        role: MemberRole.member,
        contributedAmount: 0,
        badge: MemberEntity.overdueBadgeLabel,
        overdueAmount: 200,
      );

      expect(member.showsOverdueBadge, isTrue);
    });

    test('hides when badge is not Overdue even if overdueAmount is set', () {
      final member = MemberEntity(
        id: 'u-tc',
        initials: 'TC',
        name: 'Top Contributor',
        role: MemberRole.member,
        contributedAmount: 0,
        badge: MemberEntity.topContributorBadgeLabel,
        overdueAmount: 200,
      );

      expect(member.showsOverdueBadge, isFalse);
      expect(member.showsContributionBadge, isTrue);
    });

    test('hides when overdueAmount is null or zero', () {
      const base = MemberEntity(
        id: 'u-clear',
        initials: 'CL',
        name: 'Clear User',
        role: MemberRole.member,
        contributedAmount: 0,
        badge: MemberEntity.overdueBadgeLabel,
      );

      expect(base.showsOverdueBadge, isFalse);
      expect(
        base.copyWith(overdueAmount: 0).showsOverdueBadge,
        isFalse,
      );
    });

    test('never shows Top Contributor and Overdue together', () {
      for (final badge in [
        MemberEntity.topContributorBadgeLabel,
        MemberEntity.overdueBadgeLabel,
        '',
      ]) {
        final member = MemberEntity(
          id: 'u-$badge',
          initials: 'MX',
          name: 'Mixed',
          role: MemberRole.member,
          contributedAmount: 0,
          badge: badge,
          overdueAmount: 150,
        );

        expect(
          member.showsContributionBadge && member.showsOverdueBadge,
          isFalse,
          reason: 'badge=$badge',
        );
      }
    });
  });

  group('MemberEntity.showsVffBadgeOnMemberRow', () {
    test('shows when vffConnectionState Connected and VFFAdded true', () {
      final member = MemberEntity(
        id: 'u-vff',
        userId: 'u-vff',
        initials: 'VF',
        name: 'VFF User',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
        vffAdded: true,
      );

      expect(member.showsVffBadgeOnMemberRow, isTrue);
    });

    test('hides when Connected but VFFAdded false', () {
      final member = MemberEntity(
        id: 'u-vff',
        userId: 'u-vff',
        initials: 'VF',
        name: 'VFF User',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
        vffAdded: false,
      );

      expect(member.showsVffBadgeOnMemberRow, isFalse);
    });

    test('hides when VFFAdded true but vffConnectionState not Connected', () {
      final member = MemberEntity(
        id: 'u-vff',
        userId: 'u-vff',
        initials: 'VF',
        name: 'VFF User',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.none,
        vffAdded: true,
      );

      expect(member.showsVffBadgeOnMemberRow, isFalse);
    });

    test('is false when pending outgoing even if vffAdded is true', () {
      final member = MemberEntity(
        id: 'u-co',
        userId: 'u-co',
        initials: 'TT',
        name: 'test test',
        role: MemberRole.coLeader,
        contributedAmount: 0,
        vffAdded: true,
        vffConnectionState: VffConnectionState.pendingOutgoing,
        pendingVffRequestId: 'req-1',
      );

      expect(member.showsVffBadgeOnMemberRow, isFalse);
    });

    test('is true when connected and VFFAdded', () {
      final member = MemberEntity(
        id: 'u-lead',
        userId: 'u-lead',
        initials: 'RL',
        name: 'Leader',
        role: MemberRole.leader,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
        vffAdded: true,
      );

      expect(member.showsVffBadgeOnMemberRow, isTrue);
    });

    test('is false when Connected but VFFAdded false (third-party VFF)', () {
      final member = MemberEntity(
        id: 'user-b',
        userId: 'user-b',
        initials: 'UB',
        name: 'User B',
        role: MemberRole.member,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.connected,
        vffAdded: false,
      );

      expect(member.showsVffBadgeOnMemberRow, isFalse);
      expect(member.isViewerVffLinked, isFalse);
    });
  });

  group('MemberEntityProjectRoster', () {
    ProjectDetailEntity _project(List<MemberEntity> members) {
      return ProjectDetailEntity(
        id: 'p1',
        name: 'Trip',
        category: ProjectCategory.vacations,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: members,
        borrowRequests: [],
      );
    }

    test('isProjectGroupLeaderOn prefers roster role over activity role', () {
      const leader = MemberEntity(
        id: 'gl',
        membershipId: 'leader-m',
        userId: 'gl',
        initials: 'GL',
        name: 'Leader',
        role: MemberRole.leader,
        contributedAmount: 0,
      );
      final misTagged = leader.copyWith(role: MemberRole.member);
      final project = _project([leader]);

      expect(leader.isProjectGroupLeaderOn(project), isTrue);
      expect(misTagged.isProjectGroupLeaderOn(project), isTrue);
    });

    test('withProjectRoster overlays roster role onto display member', () {
      const roster = MemberEntity(
        id: 'u2',
        membershipId: 'm2',
        userId: 'u2',
        initials: 'CL',
        name: 'Co',
        role: MemberRole.coLeader,
        contributedAmount: 0,
      );
      final activity = roster.copyWith(role: MemberRole.member);
      final project = _project([roster]);

      expect(activity.withProjectRoster(project).role, MemberRole.coLeader);
    });

    test('withProjectRoster overlays badge and overdueAmount from roster', () {
      const roster = MemberEntity(
        id: 'u3',
        membershipId: 'm3',
        userId: 'u3',
        initials: 'OD',
        name: 'Overdue',
        role: MemberRole.member,
        contributedAmount: 0,
        badge: MemberEntity.overdueBadgeLabel,
        overdueAmount: 200,
      );
      final activityMember = roster.copyWith(badge: '', overdueAmount: null);
      final project = _project([roster]);

      final merged = activityMember.withProjectRoster(project);

      expect(merged.badge, MemberEntity.overdueBadgeLabel);
      expect(merged.overdueAmount, 200);
      expect(merged.showsOverdueBadge, isTrue);
    });
  });

  group('MemberEntity.mergedWithActivity badge', () {
    test('keeps roster badge when activity API omits badge', () {
      final seed = MemberEntity(
        id: 'u1',
        membershipId: 'm1',
        userId: 'u1',
        initials: 'TC',
        name: 'Taylor',
        role: MemberRole.member,
        contributedAmount: 0,
        badge: MemberEntity.topContributorBadgeLabel,
      );
      final fromApi = seed.copyWith(badge: '');

      expect(seed.mergedWithActivity(fromApi).badge,
          MemberEntity.topContributorBadgeLabel);
    });

    test('normalizes overdue badge from activity API', () {
      final seed = MemberEntity(
        id: 'u1',
        membershipId: 'm1',
        userId: 'u1',
        initials: 'OD',
        name: 'Overdue',
        role: MemberRole.member,
        contributedAmount: 0,
      );
      final fromApi = seed.copyWith(
        badge: 'overdue',
        overdueAmount: 150,
      );

      final merged = seed.mergedWithActivity(fromApi);

      expect(merged.badge, MemberEntity.overdueBadgeLabel);
      expect(merged.showsOverdueBadge, isTrue);
    });
  });
}
