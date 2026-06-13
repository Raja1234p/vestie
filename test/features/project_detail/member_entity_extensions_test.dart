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
    MemberEntity leader({String badge = ''}) => MemberEntity(
      id: 'u1',
      initials: 'TL',
      name: 'Taylor',
      role: MemberRole.leader,
      contributedAmount: 0,
      badge: badge,
    );

    test('shows Top Contributor for leaders', () {
      expect(
        leader(badge: 'Top Contributor').showsContributionBadge,
        isTrue,
      );
    });

    test('hides role-duplicate Leader badge', () {
      expect(leader(badge: 'Leader').showsContributionBadge, isFalse);
      expect(leader(badge: 'Group Leader').showsContributionBadge, isFalse);
    });

    test('hides role-duplicate Co Leader badge', () {
      final coLeader = MemberEntity(
        id: 'u2',
        initials: 'CL',
        name: 'Casey',
        role: MemberRole.coLeader,
        contributedAmount: 0,
        badge: 'Co Leader',
      );

      expect(coLeader.showsContributionBadge, isFalse);
    });
  });

  group('MemberEntity.showsVffBadgeOnMemberRow', () {
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
  });
}
