import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity_extensions.dart';
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
      final fromApi = _member(vffConnectionState: VffConnectionState.connected);

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
}
