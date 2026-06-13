import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_pot_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/features/project_pot/domain/entities/project_pot_entity.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';
import 'package:vestie/user/features/vff/domain/entities/vff_enums.dart';

ProjectDetailEntity _vacationProject({required List<MemberEntity> members}) {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Vacation',
    category: ProjectCategory.vacations,
    status: ProjectStatus.ongoing,
    goalAmount: 50,
    currentAmount: 20,
    endsIn: '30d',
    announcement: '',
    members: members,
    borrowRequests: const [],
    viewerRole: ViewerMembershipRole.member,
    membershipId: 'viewer-m',
  );
}

void main() {
  group('ProjectDetailEntity.withProjectPot', () {
    test('updates pot amount only and leaves member VFF state unchanged', () {
      const coLeader = MemberEntity(
        id: '7b94cbd6-3493-42bd-9253-89597ea37383',
        userId: '7b94cbd6-3493-42bd-9253-89597ea37383',
        initials: 'TT',
        name: 'test test',
        role: MemberRole.coLeader,
        contributedAmount: 0,
        vffConnectionState: VffConnectionState.pendingOutgoing,
        pendingVffRequestId: 'd97721ff-d263-442c-aff6-cb5d2222ba19',
      );

      final project = _vacationProject(members: [coLeader]);
      final merged = project.withProjectPot(
        const ProjectPotEntity(
          potAmount: 35,
          contributorCount: 3,
          vffMemberUserIds: ['7b94cbd6-3493-42bd-9253-89597ea37383'],
        ),
      );

      expect(merged.currentAmount, 35);
      expect(merged.contributorCount, 3);
      expect(merged.members.single.vffAdded, isFalse);
      expect(merged.members.single.vffConnectionState,
          VffConnectionState.pendingOutgoing);
      expect(merged.members.single.showsVffBadgeOnMemberRow, isFalse);
    });
  });
}
