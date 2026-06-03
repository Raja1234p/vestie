import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/services/home_project_list_sync.dart';
import 'package:vestie/user/features/home/domain/entities/project.dart';

Project _project({
  required String id,
  double? currentAmount,
}) {
  return Project(
    id: id,
    name: 'Test',
    category: ProjectCategory.vacations,
    status: ProjectStatus.ongoing,
    relation: ProjectRelation.joined,
    goalAmount: 1000,
    currentAmount: currentAmount,
  );
}

void main() {
  test('applyPendingPots updates matching project currentAmount', () {
    HomeProjectListSync.recordContribution(
      projectId: 'p1',
      projectPot: 250,
    );

    final list = HomeProjectListSync.applyPendingPots([
      _project(id: 'p1', currentAmount: 100),
      _project(id: 'p2', currentAmount: 50),
    ]);

    expect(list[0].currentAmount, 250);
    expect(list[1].currentAmount, 50);
  });

  test('consumeRefreshHomeOnPop returns true once after contribution', () {
    HomeProjectListSync.recordContribution(
      projectId: 'p1',
      projectPot: 100,
    );
    expect(HomeProjectListSync.consumeRefreshHomeOnPop(), isTrue);
    expect(HomeProjectListSync.consumeRefreshHomeOnPop(), isFalse);
  });

  test('reconcileAfterFetch clears pending when API matches', () {
    HomeProjectListSync.recordContribution(
      projectId: 'p1',
      projectPot: 300,
    );
    HomeProjectListSync.reconcileAfterFetch([
      _project(id: 'p1', currentAmount: 300),
    ]);
    final list = HomeProjectListSync.applyPendingPots([
      _project(id: 'p1', currentAmount: 300),
    ]);
    expect(list[0].currentAmount, 300);
  });
}
