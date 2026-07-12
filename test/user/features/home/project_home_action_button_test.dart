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

    test('shows View for joined member when displayStatus is Project Not Approved', () {
      final project = joinedOngoing(displayStatus: 'Project Not Approved');
      expect(project.isProjectNotApprovedDisplayStatus, isTrue);
      expect(project.showsHomeActionButton, isTrue);
    });

    test('shows View for joined member when displayStatus is Refund in progress', () {
      final project = joinedOngoing(displayStatus: 'Refund in progress');
      expect(project.isRefundDisplayStatus, isTrue);
      expect(project.showsHomeActionButton, isTrue);
    });

    test('shows View for joined member when displayStatus is Refund complete', () {
      final project = joinedOngoing(displayStatus: 'Refund complete');
      expect(project.isRefundDisplayStatus, isTrue);
      expect(project.showsHomeActionButton, isTrue);
    });
  });
}
