import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_viewer_penalty_extensions.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  ProjectDetailEntity project({
    required List<MemberEntity> members,
    String membershipId = 'm-viewer',
    bool viewerApiIsDefaulted = false,
    double? viewerApiOverdueAmount,
  }) {
    return ProjectDetailEntity(
      id: 'p1',
      name: 'Trip',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      goalAmount: 1000,
      currentAmount: 500,
      endsIn: '30d',
      announcement: '',
      members: members,
      borrowRequests: const [],
      membershipId: membershipId,
      viewerApiIsDefaulted: viewerApiIsDefaulted,
      viewerApiOverdueAmount: viewerApiOverdueAmount,
    );
  }

  MemberEntity member({
    String membershipId = 'm-viewer',
    bool isDefaulted = false,
    double? overdueAmount,
    String badge = '',
  }) {
    return MemberEntity(
      id: 'u1',
      membershipId: membershipId,
      initials: 'MV',
      name: 'Member',
      role: MemberRole.member,
      contributedAmount: 100,
      isDefaulted: isDefaulted,
      overdueAmount: overdueAmount,
      badge: badge,
    );
  }

  group('viewer penalty eligibility', () {
    test('defaulted member cannot cast', () {
      final p = project(
        members: [member(isDefaulted: true)],
      );
      expect(p.viewerIsClosureVoteIneligible, isTrue);
      expect(p.viewerCanCastClosureVote, isFalse);
      expect(p.closureVoteCastBlockReason, ClosureVoteCastBlockReason.defaulted);
    });

    test('overdue amount blocks cast', () {
      final p = project(
        members: [member(overdueAmount: 200)],
      );
      expect(p.viewerHasOverduePenalty, isTrue);
      expect(p.closureVoteCastBlockReason, ClosureVoteCastBlockReason.overdue);
    });

    test('overdue badge blocks cast', () {
      final p = project(
        members: [member(badge: 'Overdue')],
      );
      expect(p.viewerHasOverduePenalty, isTrue);
    });

    test('viewerMembership fallback when row missing', () {
      final p = project(
        members: const [],
        viewerApiIsDefaulted: true,
      );
      expect(p.viewerIsDefaulted, isTrue);
      expect(p.viewerIsClosureVoteIneligible, isTrue);
    });

    test('eligible member can cast', () {
      final p = project(members: [member()]);
      expect(p.viewerIsClosureVoteIneligible, isFalse);
      expect(p.viewerCanCastClosureVote, isTrue);
      expect(p.closureVoteCastBlockReason, isNull);
    });
  });
}
