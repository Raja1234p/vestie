import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/viewer_membership_role.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

ProjectDetailEntity _leaderProject(ProjectCategory category) {
  return ProjectDetailEntity(
    id: 'p1',
    name: 'Test',
    category: category,
    status: ProjectStatus.ongoing,
    goalAmount: 1000,
    currentAmount: 0,
    endsIn: '30d',
    announcement: '',
    members: const [],
    borrowRequests: const [],
    viewerRole: ViewerMembershipRole.groupLeader,
  );
}

void main() {
  group('ProjectDetailEntity.canStopContributions', () {
    test('true for group leader on investment projects', () {
      expect(_leaderProject(ProjectCategory.investment).canStopContributions,
          isTrue);
    });

    test('false for group leader on vacation and emergency projects', () {
      expect(_leaderProject(ProjectCategory.vacations).canStopContributions,
          isFalse);
      expect(_leaderProject(ProjectCategory.emergency).canStopContributions,
          isFalse);
    });

    test('false for co-leader even on investment', () {
      final project = ProjectDetailEntity(
        id: 'p1',
        name: 'Test',
        category: ProjectCategory.investment,
        status: ProjectStatus.ongoing,
        goalAmount: 1000,
        currentAmount: 0,
        endsIn: '30d',
        announcement: '',
        members: const [],
        borrowRequests: const [],
        viewerRole: ViewerMembershipRole.coLeader,
      );

      expect(project.canStopContributions, isFalse);
    });
  });
}
