import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

void main() {
  group('Project.showsHomeActionButton', () {
    Project joinedOngoing({String? displayStatus}) => Project(
      id: 'p1',
      name: 'Trip',
      category: ProjectCategory.vacations,
      status: ProjectStatus.ongoing,
      relation: ProjectRelation.joined,
      displayStatus: displayStatus,
    );

    test('shows View for joined member when displayStatus is Closure Voting', () {
      final project = joinedOngoing(displayStatus: 'Closure Voting');
      expect(project.isClosureVotingDisplayStatus, isTrue);
      expect(project.showsHomeActionButton, isTrue);
    });

    test('hides View for joined member when waiting for approval', () {
      final project = joinedOngoing(displayStatus: 'Waiting for Approval');
      expect(project.showsHomeActionButton, isFalse);
    });
  });
}
